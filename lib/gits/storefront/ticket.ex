defmodule Gits.Storefront.Ticket do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true

    attribute :price, :decimal do
      allow_nil? false
      public? true
      constraints min: 0
    end

    attribute :allowed_quantity_per_user, :integer do
      allow_nil? true
      public? true
      constraints min: 0
      default 1
    end

    attribute :total_quantity, :integer do
      allow_nil? true
      public? true
      constraints min: 0
      default 100
    end

    attribute :sale_starts_at, :naive_datetime, public?: true
    attribute :sale_ends_at, :naive_datetime, public?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
    end

    has_many :instances, Gits.Storefront.TicketInstance
  end

  calculations do
    calculate :customer_reserved_instance_count_for_basket,
              :integer,
              expr(
                count(instances,
                  query: [
                    filter:
                      expr(
                        customer.user.id == ^actor(:id) and state == :reserved and
                          basket.id == ^arg(:basket_id)
                      )
                  ]
                )
              ) do
      argument :basket_id, :uuid, allow_nil?: false
    end

    calculate :customer_locked_instance_count_for_basket,
              :integer,
              expr(
                count(instances,
                  query: [
                    filter:
                      expr(
                        customer.user.id == ^actor(:id) and state == :locked_for_checkout and
                          basket.id == ^arg(:basket_id)
                      )
                  ]
                )
              ) do
      argument :basket_id, :uuid, allow_nil?: false
    end

    calculate :customer_locked_instance_price_for_basket,
              :integer,
              expr(
                price *
                  count(instances,
                    query: [
                      filter:
                        expr(
                          customer.user.id == ^actor(:id) and state == :locked_for_checkout and
                            basket.id == ^arg(:basket_id)
                        )
                    ]
                  )
              ) do
      argument :basket_id, :uuid, allow_nil?: false
    end
  end

  actions do
    default_accept :*
    defaults [:read, :destroy]

    read :read_for_shopping do
      argument :event_id, :integer, allow_nil?: false
      argument :basket_id, :uuid, allow_nil?: false
      filter expr(event.id == ^arg(:event_id))

      prepare build(
                load: [
                  customer_reserved_instance_count_for_basket: [basket_id: arg(:basket_id)]
                ]
              )

      prepare build(sort: [created_at: :asc])
    end

    read :read_for_checkout_summary do
      argument :event_id, :integer, allow_nil?: false
      argument :basket_id, :uuid, allow_nil?: false
      filter expr(event.id == ^arg(:event_id))

      prepare build(
                load: [
                  customer_locked_instance_count_for_basket: [basket_id: arg(:basket_id)],
                  customer_locked_instance_price_for_basket: [basket_id: arg(:basket_id)]
                ]
              )

      prepare build(sort: [created_at: :asc])
    end

    create :create do
      accept :*

      argument :event, :map do
        allow_nil? false
      end

      validate compare(:price, greater_than_or_equal_to: 0)

      change manage_relationship(:event, type: :append)
    end

    update :update do
      accept :*
      require_atomic? false
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

      change manage_relationship(:instance, :instances, on_match: {:destroy, :destroy})
    end
  end

  aggregates do
    first :instance_id, :instances, :id
  end

  policies do
    policy action([:read_for_shopping]) do
      authorize_if actor_present()
    end

    policy action(:read_for_checkout_summary) do
      authorize_if actor_present()
    end

    policy action(:add_instance) do
      forbid_unless expr(total_quantity == 0 or count(instances, query: [filter: expr(state not in [:cancelled])]) < total_quantity)

      forbid_unless expr(
                      allowed_quantity_per_user == 0 or
                        count(instances, query: [filter: expr(state not in [:cancelled] and customer.user.id == ^actor(:id))]) <
                          allowed_quantity_per_user
                    )

      authorize_if actor_present()
    end

    policy action(:remove_instance) do
      authorize_if actor_present()
    end

    policy action(:read) do
      authorize_if always()
    end

    policy action(:update) do
      authorize_if expr(count(instances) == 0)
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
