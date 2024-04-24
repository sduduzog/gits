defmodule Gits.Storefront.Ticket do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :price, :integer, allow_nil?: false, public?: true
    attribute :allowed_quantity_per_user, :integer, allow_nil?: true, public?: true
    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
    end

    has_many :instances, Gits.Storefront.TicketInstance

    has_many :hot_instances, Gits.Storefront.TicketInstance do
      filter expr(state in [:reserved, :added_to_basket, :ready_to_scan, :scanned])
    end
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

    update :add_instance do
      require_atomic? false

      argument :instance, :map do
        allow_nil? false
      end

      change manage_relationship(:instance, :instances, type: :create)
    end

    update :remove_instance do
      require_atomic? false

      argument :instance, :map do
        allow_nil? false
      end

      change manage_relationship(:instance, :instances, on_match: {:update, :release})
    end
  end

  calculations do
    calculate :event_name, :string, expr(event.name)
    calculate :event_starts_at, :naive_datetime, expr(event.starts_at)
    calculate :event_address_place_id, :string, expr(event.address_place_id)
    calculate :event_address, :map, Gits.Storefront.Ticket.Calculations.Address

    calculate :customer_reserved_instance_count,
              :integer,
              expr(
                count(instances,
                  query: [filter: expr(customer.id == ^actor(:id) and state == :reserved)]
                )
              )

    calculate :customer_reserved_instance_total,
              :integer,
              expr(customer_reserved_instance_count * price)

    calculate :instance_count,
              :integer,
              expr(
                count(instances,
                  query: [filter: expr(customer.id == ^actor(:id) and state == :reserved)]
                )
              )
  end

  aggregates do
    first :instance_id, :instances, :id
  end

  policies do
    policy action(:add_instance) do
      authorize_if expr(count(hot_instances) < 4)
    end

    policy action(:add_instance) do
      authorize_if expr(
                     count(hot_instances, query: [filter: expr(customer.id == ^actor(:id))]) < 1
                   )
    end

    policy action(:add_instance) do
      authorize_if actor_present()
    end

    policy action(:remove_instance) do
      authorize_if actor_present()
    end

    policy action(:read) do
      authorize_if always()
    end

    policy action(:update) do
      authorize_if expr(event.account.members.user.id == ^actor(:id))
      authorize_if always()
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
