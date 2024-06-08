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
      transition :lock_for_checkout, from: :reserved, to: :locked_for_checkout
      transition :unlock_for_shopping, from: :locked_for_checkout, to: :reserved
      transition :scan, from: :ready_to_scan, to: :scanned
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
      argument :customer, :map, allow_nil?: false
      argument :basket, :map, allow_nil?: false

      change manage_relationship(:basket, type: :append)
      change manage_relationship(:customer, type: :append)
    end

    update :lock_for_checkout do
      require_atomic? false
      change transition_state(:locked_for_checkout)
    end

    update :unlock_for_shopping do
      require_atomic? false
      change transition_state(:reserved)
    end

    update :scan do
      require_atomic? false

      change transition_state(:scanned)
    end
  end

  policies do
    policy action(:create) do
      authorize_if accessing_from(Ticket, :instances)
    end

    policy [action([:lock_for_checkout, :destroy]), accessing_from(Basket, :instances)] do
      authorize_if expr(state == :reserved)
    end

    policy [action([:read, :lock_for_checkout, :destroy]), accessing_from(Basket, :instances)] do
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy [action(:unlock_for_shopping), accessing_from(Basket, :instances)] do
      forbid_unless expr(state == :locked_for_checkout)
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy [action(:read), accessing_from(Ticket, :instances)] do
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:destroy) do
      forbid_unless expr(state == :reserved)
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
