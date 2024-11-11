defmodule Gits.Storefront.Order do
  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource, AshStateMachine]

  alias Gits.Storefront.Event
  alias __MODULE__.Changes.InitialState

  postgres do
    table "orders"
    repo Gits.Repo
  end

  state_machine do
    initial_states [:anonymous, :open]
    default_initial_state :anonymous
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:email]

      change InitialState
    end

    update :open do
    end

    update :process do
    end

    update :confirm do
    end

    update :complete do
    end

    update :refund do
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, public?: true

    create_timestamp :created_at
  end

  relationships do
    belongs_to :event, Event do
      allow_nil? false
    end
  end
end
