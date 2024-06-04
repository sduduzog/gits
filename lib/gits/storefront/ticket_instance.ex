defmodule Gits.Storefront.TicketInstance do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine],
    domain: Gits.Storefront

  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Ticket

  attributes do
    integer_primary_key :id

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  state_machine do
    initial_states [:reserved]
    default_initial_state :reserved

    transitions do
      transition :abandon, from: :added_to_basket, to: :abandoned
      transition :ready_to_scan, from: :added_to_basket, to: :ready_to_scan
      transition :scan, from: :ready_to_scan, to: :scanned
      transition :release, from: :reserved, to: :released
    end
  end

  relationships do
    belongs_to :ticket, Ticket
    belongs_to :customer, Customer
    belongs_to :basket, Basket
  end

  calculations do
    calculate :price, :decimal, expr(ticket.price)

    calculate :ticket_name, :string, expr(ticket.name)
    calculate :event_name, :string, expr(ticket.event.name)
    calculate :event_starts_at, :naive_datetime, expr(ticket.event.starts_at)
  end

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      argument :ticket, :map, allow_nil?: false
      argument :customer, :map, allow_nil?: false

      change manage_relationship(:ticket, type: :append)
      change manage_relationship(:customer, type: :append)
    end

    update :abandon do
      require_atomic? false

      change transition_state(:abandoned)
    end

    update :release do
      require_atomic? false

      change transition_state(:released)
    end

    update :ready_to_scan do
      require_atomic? false

      change transition_state(:ready_to_scan)
    end

    update :scan do
      require_atomic? false

      change transition_state(:scanned)
    end
  end

  policies do
    policy action(:create) do
      authorize_if actor_present()
    end

    policy [action(:destroy), accessing_from(Basket, :instances)] do
      forbid_if expr(state != :reserved)
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy [action(:read), accessing_from(Ticket, :instances)] do
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action([:read, :destroy]) do
      authorize_if actor_present()
    end

    policy action(:ready_to_scan) do
      authorize_if always()
    end

    policy action(:abandon) do
      authorize_if always()
    end

    policy action(:release) do
      authorize_if always()
    end
  end

  postgres do
    table "ticket_instances"
    repo Gits.Repo
  end
end
