defmodule Gits.Storefront.Ticket do
  require Decimal

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  alias Gits.Storefront.Event
  alias Gits.Storefront.TicketInstance

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true

    attribute :price_in_cents, :integer do
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

    attribute :availability, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:open, :restricted]
      default :open
    end

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
    calculate :price, :decimal, expr(round(price_in_cents / 100, 2))

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

    calculate :customer_reserved_instance_price_for_basket,
              :decimal,
              expr(
                round(
                  price_in_cents *
                    count(instances,
                      query: [
                        filter:
                          expr(
                            customer.user.id == ^actor(:id) and state == :reserved and
                              basket.id == ^arg(:basket_id)
                          )
                      ]
                    ) / 100,
                  2
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
    defaults [:destroy]

    read :read do
      primary? true
      prepare build(load: [:price])
    end

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
      accept [
        :name,
        :allowed_quantity_per_user,
        :total_quantity,
        :sale_starts_at,
        :sale_ends_at,
        :availability
      ]

      argument :price, :decimal do
        allow_nil? false
        constraints min: 0
      end

      argument :event, :map do
        allow_nil? false
      end

      change before_action(fn changeset, _ ->
               price = changeset |> Ash.Changeset.get_argument(:price)

               changeset
               |> Ash.Changeset.change_attribute(
                 :price_in_cents,
                 price |> Decimal.mult(100) |> Decimal.to_integer()
               )
             end)

      change manage_relationship(:event, type: :append)
    end

    update :update do
      accept :*
      require_atomic? false

      argument :price, :decimal do
        allow_nil? false
        constraints min: 0
      end

      change before_action(fn changeset, _ ->
               price = changeset |> Ash.Changeset.get_argument(:price)

               changeset
               |> Ash.Changeset.change_attribute(
                 :price_in_cents,
                 price |> Decimal.mult(100) |> Decimal.to_integer()
               )
             end)
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
      authorize_if Gits.Storefront.Checks.TicketSaleStartDateIsBefore
    end

    policy action(:add_instance) do
      authorize_if Gits.Storefront.Checks.TicketSaleEndDateIsAhead
    end

    policy action(:add_instance) do
      forbid_unless expr(
                      total_quantity == 0 or
                        count(instances, query: [filter: expr(state not in [:cancelled])]) <
                          total_quantity
                    )

      forbid_unless expr(
                      allowed_quantity_per_user == 0 or
                        count(instances,
                          query: [
                            filter:
                              expr(state not in [:cancelled] and customer.user.id == ^actor(:id))
                          ]
                        ) <
                          allowed_quantity_per_user
                    )

      authorize_if actor_present()
    end

    policy action(:add_instance) do
      authorize_if expr(
                     allowed_quantity_per_user == 0 or
                       count(instances,
                         query: [
                           filter:
                             expr(state not in [:cancelled] and customer.user.id == ^actor(:id))
                         ]
                       ) <
                         allowed_quantity_per_user
                   )
    end

    policy action(:add_instance) do
      authorize_if expr(
                     total_quantity == 0 or
                       count(instances, query: [filter: expr(state not in [:cancelled])]) <
                         total_quantity
                   )
    end

    policy action(:remove_instance) do
      authorize_if actor_present()
    end

    policy action(:read) do
      authorize_if accessing_from(TicketInstance, :ticket)
      authorize_if accessing_from(Event, :tickets)
      authorize_if expr(event.baskets.customer.user.id == ^actor(:id))
    end

    policy action(:create) do
      authorize_if actor_present()
    end

    policy action(:destroy) do
      authorize_if expr(
                     event.account.members.user.id == ^actor(:id) and
                       event.account.members.role in [:owner]
                   )

      authorize_if actor_present()
    end

    policy action(:update) do
      authorize_if expr(count(instances) == 0)
    end

    policy action(:update) do
      authorize_if expr(event.account.members.user.id == ^actor(:id))
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
