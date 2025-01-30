defmodule Gits.Storefront.Event do
  require Decimal
  alias Gits.Bucket
  alias Gits.Accounts.{Host, Venue}
  alias Gits.Storefront.{EventCategory, Interaction, Order, Ticket, TicketType, Webhook}

  alias __MODULE__.Notifiers.{EventUpdated}
  alias __MODULE__.Fragments

  use Ash.Resource,
    domain: Gits.Storefront,
    fragments: [Fragments.Actions, Fragments.Policies],
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshPaperTrail.Resource],
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

    has_many :webhooks, Webhook

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
    calculate :poster_invalid?, :boolean, expr(is_nil(poster))
    calculate :venue_invalid?, :boolean, expr(is_nil(venue))

    calculate :currently_happening?,
              :boolean,
              expr(utc_starts_at < fragment("now()") and fragment("now()") < utc_ends_at)

    calculate :has_paid_tickets?,
              :boolean,
              expr(count(ticket_types, query: [filter: expr(price > 0)]) > 0)

    calculate :ticket_prices_vary?, :boolean, expr(minimum_ticket_price != maximum_ticket_price)
  end

  aggregates do
    count :total_ticket_types, :ticket_types

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
