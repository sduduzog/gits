defmodule Gits.Storefront.Ticket do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :price, :integer, allow_nil?: false, public?: true
    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
    end

    has_many :instances, Gits.Storefront.TicketInstance
  end

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    create :create do
      accept :*

      argument :event, :map do
        allow_nil? false
      end

      validate compare(:price, greater_than_or_equal_to: 0)

      change manage_relationship(:event, type: :append)
    end
  end

  calculations do
    calculate :event_name, :string, expr(event.name)
    calculate :event_starts_at, :naive_datetime, expr(event.starts_at)
    calculate :event_address_place_id, :string, expr(event.address_place_id)
    calculate :event_address, :map, Gits.Storefront.Ticket.Calculations.Address

    calculate :instance_count,
              :integer,
              expr(count(instances, query: [filter: expr(customer.user.id == ^actor(:id))]))
  end

  aggregates do
    first :instance_id, :instances, :id
  end

  policies do
    policy action(:read) do
      forbid_if expr(price > 0)
      authorize_if Gits.Checks.CanRead
    end

    policy action([:create, :destroy]) do
      authorize_if always()
    end
  end

  postgres do
    table "tickets"
    repo Gits.Repo
  end
end

defmodule Gits.Storefront.Ticket.Calculations.Address do
  use Ash.Resource.Calculation

  def load(_, _, _) do
    [:event_address_place_id]
  end

  def calculate(records, _opts, _context) do
    Enum.map(records, fn record ->
      Gits.Cache.get_address(record.event_address_place_id)
    end)
  end
end
