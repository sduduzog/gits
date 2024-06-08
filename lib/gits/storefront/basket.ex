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
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id

    attribute :amount, :decimal, allow_nil?: false, public?: true

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  state_machine do
    initial_states [:open]
    default_initial_state :open

    transitions do
      transition :lock_for_checkout, from: :open, to: :locked_for_checkout
      transition :unlock_for_shopping, from: :locked_for_checkout, to: :open
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

      change set_attribute(:amount, 0)
      change manage_relationship(:event, type: :append)
      change manage_relationship(:customer, type: :append)
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

    update :settle do
      transition_state(:refunded)
    end

    update :refund do
      transition_state(:refunded)
    end
  end

  policies do
    policy action(:lock_for_checkout) do
      forbid_unless expr(state == :open)
      forbid_unless expr(count_of_instances > 0)
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:unlock_for_shopping) do
      forbid_unless expr(state == :locked_for_checkout)
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
