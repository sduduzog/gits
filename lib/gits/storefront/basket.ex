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

    attribute :amount, :integer, allow_nil?: false, public?: true

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  state_machine do
    initial_states [:open]
    default_initial_state :open

    transitions do
    end
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
    end

    has_many :instances, Gits.Storefront.TicketInstance
  end

  actions do
    defaults [:read]

    create :open_basket do
    end

    update :add_ticket_to_basket do
      transition_state(:refunded)
    end

    update :remove_ticket_from_basket do
      transition_state(:refunded)
    end

    update :package_tickets do
      transition_state(:refunded)
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
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "baskets"
    repo Gits.Repo
  end
end
