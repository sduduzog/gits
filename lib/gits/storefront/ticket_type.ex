defmodule Gits.Storefront.TicketType do
  alias Gits.Storefront.{Event, Ticket}
  alias __MODULE__.Validations.PriceValid
  alias __MODULE__.Fragments

  use Ash.Resource,
    domain: Gits.Storefront,
    fragments: [Fragments.Policies],
    data_layer: AshPostgres.DataLayer,
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

  calculations do
    calculate :utc_sale_starts_at,
              :utc_datetime,
              expr(fragment("? at time zone (?)", sale_starts_at, "Africa/Johannesburg"))

    calculate :utc_sale_ends_at,
              :utc_datetime,
              expr(fragment("? at time zone (?)", sale_ends_at, "Africa/Johannesburg"))

    calculate :sale_started?, :boolean, expr(utc_sale_starts_at < fragment("now()"))
    calculate :sale_ended?, :boolean, expr(utc_sale_ends_at < fragment("now()"))
    calculate :on_sale?, :boolean, expr(sale_started? and not sale_ended?)

    calculate :sold_out, :boolean, expr(valid_tickets_count == quantity)

    calculate :limit_reached,
              :boolean,
              expr(
                count(tickets,
                  query: [
                    filter: expr(state != :released and order.email == ^arg(:email))
                  ]
                ) ==
                  limit_per_user
              ) do
      argument :email, :ci_string
    end
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
