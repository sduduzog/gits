defmodule Gits.Storefront.TicketType do
  alias Gits.Storefront.{Event, Order, Ticket}
  alias Gits.Accounts
  alias Gits.Accounts.User
  alias __MODULE__.Validations.PriceValid
  alias __MODULE__.Fragments

  use Ash.Resource,
    domain: Gits.Storefront,
    fragments: [Fragments.Calculations],
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshPaperTrail.Resource]

  postgres do
    table "ticket_types"
    repo Gits.Repo
  end

  paper_trail do
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  actions do
    defaults [:destroy, update: :*]

    read :read do
      primary? true

      prepare build(sort: [order_index: :asc])
    end

    create :create do
      primary? true
      accept :*

      argument :event, :map

      change set_new_attribute(:color, &Gits.RandomColor.generate/0)
      change manage_relationship(:event, type: :append)
    end

    update :order do
      argument :index, :integer, allow_nil?: false

      change set_new_attribute(:order_index, arg(:index))
    end

    update :add_ticket do
      require_atomic? false
      argument :ticket, :map, allow_nil?: false

      change manage_relationship(:ticket, :tickets, type: :create)
    end

    update :remove_ticket do
      require_atomic? false
      argument :ticket, :map, allow_nil?: false

      change manage_relationship(:ticket, :tickets, on_match: :destroy)
    end
  end

  policies do
    policy action(:read) do
      authorize_if accessing_from(Event, :ticket_types)
      authorize_if accessing_from(Order, :ticket_types)
      authorize_if accessing_from(Ticket, :ticket_type)
    end

    policy action(:create) do
      authorize_if actor_present()
      authorize_if accessing_from(Event, :ticket_types)
    end

    policy action([:update, :order]) do
      authorize_if actor_present()
      authorize_if accessing_from(Order, :ticket_types)
      authorize_if accessing_from(Event, :ticket_types)
    end

    policy action(:destroy) do
      authorize_if actor_present()
      authorize_if accessing_from(Event, :ticket_types)
    end

    policy action(:add_ticket) do
      authorize_if accessing_from(Order, :ticket_types)
    end

    policy action(:add_ticket) do
      authorize_if expr(on_sale?)
    end

    policy action(:add_ticket) do
      authorize_if expr(valid_tickets_count < quantity)
    end

    policy action(:remove_ticket) do
      authorize_if accessing_from(Order, :ticket_types)
    end
  end

  validations do
    validate {PriceValid, [:price]}
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true, allow_nil?: false
    attribute :price, :decimal, public?: true, allow_nil?: false, default: 0
    attribute :description, :string, public?: true

    attribute :sale_starts_at, :naive_datetime, public?: true, allow_nil?: false
    attribute :sale_ends_at, :naive_datetime, public?: true, allow_nil?: false

    attribute :quantity, :integer, public?: true, allow_nil?: false, default: 10
    attribute :limit_per_user, :integer, public?: true, allow_nil?: false, default: 10

    attribute :color, :string, public?: true

    attribute :rsvp_enabled, :boolean, public?: true, allow_nil?: false, default: false

    attribute :order_index, :integer, public?: true, allow_nil?: false, default: 0

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, Event do
      allow_nil? false
    end

    has_many :tickets, Ticket
  end

  aggregates do
    count :valid_tickets_count, :tickets do
      filter expr(state in [:ready, :checked_in, :admitted])
    end

    count :active_tickets_count, :tickets do
      filter expr(order.state == :completed)
    end
  end
end
