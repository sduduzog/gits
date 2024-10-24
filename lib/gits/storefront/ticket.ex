defmodule Gits.Storefront.Ticket do
  require Decimal
  require Ash.Query

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  alias Gits.Storefront.Calculations.TicketToken
  alias Gits.Storefront.{Event, TicketInstance, TicketInvite}

  postgres do
    table "tickets"
    repo Gits.Repo
  end

  actions do
    default_accept :*
    defaults [:destroy]

    read :read do
      primary? true
      prepare build(load: [:price, :local_sale_starts_at, :local_sale_ends_at])
    end

    read :with_token do
      argument :token, :string, allow_nil?: false

      prepare before_action(fn query, _ ->
                token =
                  query
                  |> Ash.Query.get_argument(:token)

                [ticket_id, user_id] =
                  ExBase58.decode!(token)
                  |> String.split(":")

                query |> Ash.Query.filter(id: ticket_id)
              end)

      prepare build(load: [:event])
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

      argument :local_sale_starts_at, :naive_datetime do
        allow_nil? false
      end

      argument :local_sale_ends_at, :naive_datetime do
        allow_nil? false
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

      change {Gits.Storefront.Changes.SetLocalTimezone,
              attribute: :sale_starts_at, input: :local_sale_starts_at}

      change {Gits.Storefront.Changes.SetLocalTimezone,
              attribute: :sale_ends_at, input: :local_sale_ends_at}
    end

    update :update do
      accept :*
      require_atomic? false

      argument :price, :decimal do
        allow_nil? false
        constraints min: 0
      end

      argument :local_sale_starts_at, :naive_datetime do
        allow_nil? false
      end

      argument :local_sale_ends_at, :naive_datetime do
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

      change {Gits.Storefront.Changes.SetLocalTimezone,
              attribute: :sale_starts_at, input: :local_sale_starts_at}

      change {Gits.Storefront.Changes.SetLocalTimezone,
              attribute: :sale_ends_at, input: :local_sale_ends_at}
    end

    update :add_instance do
      require_atomic? false

      argument :basket, :map do
        allow_nil? false
      end

      argument :customer, :map do
        allow_nil? false
      end

      change fn changeset, %{actor: actor} = context ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          basket = changeset |> Ash.Changeset.get_argument(:basket)
          customer = changeset |> Ash.Changeset.get_argument(:customer)

          changeset
          |> Ash.Changeset.manage_relationship(
            :instances,
            [%{basket: basket, customer: customer}],
            type: :create
          )
        end)
      end
    end

    update :remove_instance do
      require_atomic? false

      argument :id, :integer do
        allow_nil? false
      end

      change fn changeset, %{actor: actor} = context ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          instance_id = changeset |> Ash.Changeset.get_argument(:id)

          changeset
          |> Ash.Changeset.manage_relationship(:instances, [instance_id],
            on_match: {:destroy, :destroy}
          )
        end)
      end
    end

    update :add_invite_instance do
      require_atomic? false

      argument :basket, :map do
        allow_nil? false
      end

      argument :customer, :map do
        allow_nil? false
      end

      change fn changeset, %{actor: actor} = context ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          basket = changeset |> Ash.Changeset.get_argument(:basket)
          customer = changeset |> Ash.Changeset.get_argument(:customer)

          changeset
          |> Ash.Changeset.manage_relationship(
            :instances,
            [%{basket: basket, customer: customer}],
            on_no_match: {:create, :create_for_invite},
            on_match: :ignore
          )
        end)
      end
    end
  end

  policies do
    policy [action(:read), accessing_from(Basket, :tickets)] do
      authorize_if always()
    end

    policy action(:with_token) do
      authorize_if actor_present()
    end

    policy action([:add_instance, :add_invite_instance]) do
      authorize_unless Gits.Storefront.Checks.TicketSoldOut
    end

    policy action(:remove_instance) do
      authorize_if actor_present()
    end

    policy action(:read) do
      authorize_if accessing_from(TicketInvite, :ticket)
      authorize_if accessing_from(TicketInstance, :ticket)
      authorize_if accessing_from(Event, :tickets)
      authorize_if expr(event.account.members.user.id == ^actor(:id))
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

    policy [action(:update), changing_attributes([:price_in_cents])] do
      authorize_if expr(count(instances) == 0)
    end

    policy action(:update) do
      authorize_if expr(event.account.members.user.id == ^actor(:id))
      authorize_if always()
    end
  end

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

    attribute :sale_starts_at, :datetime, public?: true
    attribute :sale_ends_at, :datetime, public?: true

    attribute :availability, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:public, :invite_only]
      default :open
    end

    attribute :test, :boolean do
      default false
    end

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
    end

    has_many :instances, Gits.Storefront.TicketInstance

    has_many :invites, Gits.Storefront.TicketInvite
  end

  calculations do
    calculate :price, :decimal, expr(round(price_in_cents / 100, 2))

    calculate :token, :string, TicketToken

    calculate :local_sale_starts_at,
              :naive_datetime,
              {Gits.Storefront.Calculations.LocalDatetime, attribute: :sale_starts_at}

    calculate :local_sale_ends_at,
              :naive_datetime,
              {Gits.Storefront.Calculations.LocalDatetime, attribute: :sale_ends_at}

    calculate :sold_out?,
              :boolean,
              expr(
                count(instances,
                  query: [
                    filter: expr(basket.state in [:settled_for_free, :settled_for_payment])
                  ]
                ) >=
                  total_quantity and total_quantity > 0
              )

    calculate :sold_out_for_actor?,
              :boolean,
              expr(
                count(instances,
                  query: [
                    filter:
                      expr(
                        basket.state in [:settled_for_free, :settled_for_payment] and
                          customer.user.id == ^actor(:id)
                      )
                  ]
                ) >=
                  allowed_quantity_per_user and sold_out? == false
              )
  end

  aggregates do
    count :total_sold, :instances do
      filter expr(
               basket.state in [:settled_for_free, :settled_for_payment, :invited] and
                 ticket.test == false
             )
    end

    count :invites_count, :invites
  end

  aggregates do
    first :instance_id, :instances, :id
  end
end
