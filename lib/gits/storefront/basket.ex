defmodule Gits.Storefront.Basket do
  require Ash.Query
  require Ash.Resource.Change.Builtins
  require Ash.Resource.Change.Builtins
  require Ash.Resource.Change.Builtins
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine],
    domain: Gits.Storefront,
    notifiers: [Ash.Notifier.PubSub]

  alias Gits.Storefront.Notifiers.StartBasketJob
  alias Gits.Storefront.TicketInstance

  attributes do
    uuid_primary_key :id

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  state_machine do
    initial_states [:open]
    default_initial_state :open

    transitions do
      transition :lock_for_checkout, from: :open, to: :locked_for_checkout
      transition :unlock_for_shopping, from: :locked_for_checkout, to: :open
      transition :cancel, from: [:open, :locked_for_checkout], to: :cancelled
      transition :settle_for_free, from: :locked_for_checkout, to: :settled_for_free
    end
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
    end

    belongs_to :customer, Gits.Storefront.Customer

    has_many :instances, Gits.Storefront.TicketInstance
  end

  aggregates do
    count :count_of_instances, :instances
    sum :sum_of_instance_prices, :instances, :price
  end

  actions do
    defaults [:read]

    read :read_for_shopping do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      prepare build(load: [:count_of_instances, :sum_of_instance_prices, :instances])
    end

    read :read_for_checkout_summary do
      argument :id, :uuid, allow_nil?: false
      filter expr(id == ^arg(:id))
      prepare build(load: [:count_of_instances, :sum_of_instance_prices, :instances])
    end

    create :open_basket do
      argument :event, :map, allow_nil?: false
      argument :customer, :map, allow_nil?: false

      change manage_relationship(:event, type: :append)
      change manage_relationship(:customer, type: :append)

      notifiers [StartBasketJob]
    end

    update :add_ticket_to_basket do
      require_atomic? false
      argument :instance, :map, allow_nil?: false

      change manage_relationship(:instance, :instances, type: :create)
    end

    update :remove_ticket_from_basket do
      require_atomic? false

      argument :instance, :integer, allow_nil?: false

      change manage_relationship(:instance, :instances,
               on_no_match: :error,
               on_match: {:destroy, :destroy}
             )
    end

    update :lock_for_checkout do
      require_atomic? false

      change transition_state(:locked_for_checkout)

      change fn changeset, _ ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          changeset
          |> Ash.Changeset.manage_relationship(
            :instances,
            Enum.map(changeset.data.instances, & &1.id),
            on_match: {:update, :lock_for_checkout}
          )
        end)
      end
    end

    update :unlock_for_shopping do
      require_atomic? false

      change transition_state(:open)

      change fn changeset, _ ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          changeset
          |> Ash.Changeset.manage_relationship(
            :instances,
            Enum.map(changeset.data.instances, & &1.id),
            on_match: {:update, :unlock_for_shopping}
          )
        end)
      end
    end

    update :cancel do
      require_atomic? false

      change fn changeset, %{actor: actor} ->
        instances =
          case actor do
            %Oban.Job{} ->
              TicketInstance
              |> Ash.Query.for_read(:read, %{}, actor: actor)
              |> Ash.Query.filter(basket.id == ^changeset.data.id)
              |> Ash.read!()

            _ ->
              changeset.data
              |> Ash.load!(:instances, actor: actor)
              |> Map.get(:instances)
          end

        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          changeset
          |> Ash.Changeset.manage_relationship(
            :instances,
            Enum.map(instances, & &1.id),
            on_match: {:update, :cancel}
          )
        end)
      end

      change transition_state(:cancelled)
    end

    update :settle_for_free do
      change transition_state(:settled_for_free)
    end

    update :refund do
      transition_state(:refunded)
    end
  end

  pub_sub do
    module GitsWeb.Endpoint
    prefix "basket"
    publish :cancel, ["cancelled", :id]
  end

  policies do
    policy action(:lock_for_checkout) do
      forbid_unless expr(count_of_instances > 0)
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:unlock_for_shopping) do
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:read_for_shopping) do
      forbid_unless expr(state == :open)
      forbid_unless expr(customer.user.id == ^actor(:id))
      authorize_if actor_present()
    end

    policy action(:read_for_checkout_summary) do
      forbid_unless expr(state == :locked_for_checkout)
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:add_ticket_to_basket) do
      authorize_if actor_present()
    end

    bypass action(:cancel) do
      authorize_if Gits.Checks.ActorIsObanJob
    end

    policy action(:cancel) do
      forbid_unless expr(customer.user.id == ^actor(:id))
      authorize_if actor_present()
    end

    policy action(:read) do
      authorize_if Gits.Checks.ActorIsObanJob
    end

    policy action([
             :open_basket,
             :lock_for_checkout,
             :unlock_for_shopping
           ]) do
      authorize_if actor_present()
    end
  end

  postgres do
    table "baskets"
    repo Gits.Repo
  end
end
