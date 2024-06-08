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
      transition :package_tickets, from: :open, to: :packaged
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
      filter expr(state == :open)
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

    update :package_tickets do
      require_atomic? false

      change fn changeset, _ ->
        Ash.Changeset.change_attribute(changeset, :amount, changeset.data.sum_of_instance_prices)
      end

      transition_state(:packaged)
    end

    update :package_timeout do
      transition_state(:refunded)
    end

    update :settle_timeout do
      transition_state(:refunded)
    end

    update :settle_for_free do
      transition_state(:refunded)
    end

    update :settle do
      transition_state(:refunded)
    end

    update :refund do
      transition_state(:refunded)
    end
  end

  policies do
    policy action(:read_for_shopping) do
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action([:add_ticket_to_basket, :remove_ticket_from_basket]) do
      authorize_if expr(state == :open)
    end

    policy action([
             :open_basket,
             :package_tickets,
             :read_for_shopping,
             :add_ticket_to_basket,
             :remove_ticket_from_basket
           ]) do
      authorize_if actor_present()
    end
  end

  postgres do
    table "baskets"
    repo Gits.Repo
  end
end
