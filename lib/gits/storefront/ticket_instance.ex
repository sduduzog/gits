defmodule Gits.Storefront.TicketInstance do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  attributes do
    integer_primary_key :id

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :ticket, Gits.Storefront.Ticket
    belongs_to :customer, Gits.Storefront.Customer
  end

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    create :create do
      accept :*

      argument :ticket, :map
      argument :customer, :map

      change manage_relationship(:ticket, type: :append)
      change manage_relationship(:customer, type: :append)
    end
  end

  calculations do
    calculate :ticket_name, :string, expr(ticket.name)
    calculate :event_name, :string, expr(ticket.event.name)
    calculate :event_starts_at, :naive_datetime, expr(ticket.event.starts_at)
    calculate :event_address_place_id, :string, expr(ticket.event.address_place_id)
    calculate :event_address, :map, Gits.Storefront.TicketInstance.Calculations.Address
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "ticket_instances"
    repo Gits.Repo
  end
end

defmodule Gits.Storefront.TicketInstance.Calculations.Address do
  use Ash.Resource.Calculation

  def load(_, _, _) do
    [:event_address_place_id]
  end

  def calculate(records, opts, context) do
    Enum.map(records, fn record ->
      Gits.Cache.get_address(record.event_address_place_id)
    end)
  end
end
