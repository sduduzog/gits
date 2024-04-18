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
    calculate :customer_instance_count,
              :integer,
              expr(count(instances, query: [filter: expr(customer == ^actor(:id))]))
  end

  policies do
    policy action(:read) do
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
