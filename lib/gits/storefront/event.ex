defmodule Gits.Storefront.Event do
  require Decimal
  alias Gits.Bucket
  alias Gits.Accounts.{Host, Venue}
  alias Gits.Storefront.{EventCategory, Interaction, Order, Ticket, TicketType}

  alias __MODULE__.Checks.ActorCanCreateEvent
  alias __MODULE__.Notifiers.{EventUpdated}

  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshStateMachine, AshPaperTrail.Resource],
    notifiers: [EventUpdated]

  postgres do
    table "events"
    repo Gits.Repo
  end

  archive do
    exclude_read_actions :archived
  end

  state_machine do
    initial_states [:draft]
    default_initial_state :draft

    transitions do
      transition :publish, from: :draft, to: :published
      transition :complete, from: :published, to: :completed
    end
  end

  paper_trail do
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  code_interface do
    define :publish_event, action: :publish
    define :get_by_public_id_for_listing, args: [:public_id]
  end

  actions do
    defaults [:read, :destroy, update: :*]

    read :get_by_public_id_for_listing do
      get_by [:public_id]
      prepare build(load: [:name])
    end

    read :archived do
      filter expr(not is_nil(archived_at))
    end

    create :create do
      primary? true
      accept [:name, :starts_at, :ends_at, :visibility]

      argument :host, :map
      argument :poster, :map

      change manage_relationship(:host, type: :append)
      change manage_relationship(:poster, type: :append)
    end

    update :details do
      require_atomic? false
      accept :*

      argument :poster, :map

      change manage_relationship(:poster,
               on_lookup: :relate,
               on_missing: :unrelate,
               on_no_match: :error
             )
    end

    update :sort_ticket_types do
      require_atomic? false

      argument :ticket_types, {:array, :map}
      change manage_relationship(:ticket_types, on_match: {:update, :order})
    end

    update :location do
      accept [:location_notes, :location_is_private]
    end

    update :create_venue do
      require_atomic? false

      argument :venue, :map, allow_nil?: false
      change manage_relationship(:venue, type: :create)
    end

    update :use_venue do
      require_atomic? false

      argument :venue, :uuid, allow_nil?: false
      change manage_relationship(:venue, type: :append)
    end

    update :remove_venue do
      require_atomic? false

      argument :venue, :uuid, allow_nil?: false
      change manage_relationship(:venue, type: :remove)
    end

    update :description do
      accept [:summary, :description]
    end

    update :publish do
      change atomic_update(:published_at, expr(fragment("now()")))
      change transition_state(:published)
    end

    update :add_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, type: :create)
    end

    update :edit_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, on_match: :update)
    end

    update :archive_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, on_match: :destroy)
    end

    update :create_order do
      require_atomic? false

      argument :order, :map, allow_nil?: false
      change manage_relationship(:order, :orders, type: :create)
    end

    update :complete do
      change atomic_update(:completed_at, expr(fragment("now()")))
      change transition_state(:completed)
    end
  end

  policies do
    policy action(:read) do
      authorize_if expr(not is_nil(published_at))
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:archived) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:create) do
      authorize_if ActorCanCreateEvent
    end

    policy action(:details) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy changing_attributes(visibility: [from: :private, to: :public]) do
      authorize_if expr(host.state == :verified)
    end

    policy action(:create_venue) do
      authorize_if actor_present()
    end

    policy action(:use_venue) do
      authorize_if actor_present()
    end

    policy action(:remove_venue) do
      authorize_if actor_present()
    end

    policy action(:location) do
      authorize_if actor_present()
    end

    policy action(:description) do
      authorize_if actor_present()
    end

    policy action(:media) do
      authorize_if actor_present()
    end

    policy action(:add_ticket_type) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:edit_ticket_type) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:archive_ticket_type) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:sort_ticket_types) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:publish) do
      authorize_if expr(exists(host.roles, user.id == ^actor(:id)))
    end

    policy action(:publish) do
      authorize_if expr(not start_date_invalid?)
    end

    policy action(:publish) do
      authorize_if expr(not end_date_invalid?)
    end

    policy action(:publish) do
      authorize_if expr(not venue_invalid?)
    end

    policy action(:create_order) do
      authorize_if always()
    end

    policy action(:destroy) do
      authorize_if always()
    end

    policy action(:complete) do
      authorize_if actor_attribute_equals(
                     :worker,
                     to_string(EventUpdated) |> String.replace("Elixir.", "")
                   )
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :public_id, :string,
      allow_nil?: false,
      writable?: false,
      public?: true,
      default: &Nanoid.generate/0

    attribute :name, :string, public?: true, allow_nil?: false
    attribute :starts_at, :naive_datetime, public?: true, allow_nil?: false
    attribute :ends_at, :naive_datetime, public?: true, allow_nil?: false
    attribute :category, EventCategory, public?: true, allow_nil?: false, default: :other
    attribute :visibility, :atom, public?: true, constraints: [one_of: [:private, :public]]

    attribute :location_notes, :string, public?: true
    attribute :location_is_private, :boolean, public?: true, default: false

    attribute :summary, :string, public?: true
    attribute :description, :string, public?: true

    attribute :published_at, :utc_datetime, public?: true
    attribute :completed_at, :utc_datetime, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :host, Host do
      allow_nil? false
    end

    belongs_to :venue, Venue

    has_many :ticket_types, TicketType

    has_many :tickets, Ticket do
      no_attributes? true
      filter expr(state in [:ready, :admitted] and ticket_type.id == parent(ticket_types.id))
    end

    has_many :orders, Order
    has_many :interactions, Interaction

    has_one :poster, Bucket.Image do
      domain Bucket
    end
  end

  calculations do
    calculate :published?, :boolean, expr(not is_nil(published_at))

    calculate :utc_starts_at,
              :utc_datetime,
              expr(fragment("? at time zone (?)", starts_at, "Africa/Johannesburg"))

    calculate :utc_ends_at,
              :utc_datetime,
              expr(fragment("? at time zone (?)", ends_at, "Africa/Johannesburg"))

    calculate :start_date_invalid?, :boolean, expr(utc_starts_at < fragment("now()"))
    calculate :end_date_invalid?, :boolean, expr(utc_ends_at < utc_starts_at)
    calculate :venue_invalid?, :boolean, expr(is_nil(venue))

    calculate :ticket_prices_vary?, :boolean, expr(minimum_ticket_price != maximum_ticket_price)
  end

  aggregates do
    count :unique_views, :interactions do
      field :viewer_id
      uniq? true
    end

    count :total_orders, :orders do
      filter state: :completed
    end

    count :admissions, [:ticket_types, :tickets] do
      join_filter [:ticket_types, :tickets], expr(not is_nil(admitted_at))
    end

    min :minimum_ticket_price, :ticket_types, :price, default: Decimal.new(0)
    max :maximum_ticket_price, :ticket_types, :price, default: Decimal.new(0)

    sum :total_revenue, :orders, :total, default: Decimal.new(0)

    sum :actual_revenue, [:orders, :fees_split], :subaccount, default: Decimal.new(0)
  end
end
