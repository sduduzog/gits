defmodule Gits.Storefront.TicketInstance do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine],
    domain: Gits.Storefront

  attributes do
    integer_primary_key :id

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  state_machine do
    initial_states [:reserved]
    default_initial_state :reserved

    transitions do
      transition :add_to_basket, from: :reserved, to: :added_to_basket
      transition :abandon, from: :added_to_basket, to: :abandoned
      transition :ready_to_scan, from: :added_to_basket, to: :ready_to_scan
      transition :scan, from: :ready_to_scan, to: :scanned
      transition :release, from: :reserved, to: :released
    end
  end

  relationships do
    belongs_to :ticket, Gits.Storefront.Ticket
    belongs_to :customer, Gits.Storefront.Customer
    belongs_to :basket, Gits.Storefront.Basket
  end

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    create :create do
      accept :*
      argument :ticket, :map
      argument :customer, :map

      change manage_relationship(:ticket, type: :append)
      change manage_relationship(:customer, type: :append)
    end

    update :add_to_basket do
      require_atomic? false

      change transition_state(:added_to_basket)
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

  calculations do
    calculate :ticket_name, :string, expr(ticket.name)
    calculate :event_name, :string, expr(ticket.event.name)
    calculate :event_starts_at, :naive_datetime, expr(ticket.event.starts_at)
    calculate :event_address_place_id, :string, expr(ticket.event.address_place_id)
    calculate :event_address, :map, Gits.Storefront.TicketInstance.Calculations.Address
  end

  policies do
    policy action([:read, :create]) do
      authorize_if expr(customer.user.id == ^actor(:id))
      authorize_if always()
    end

    bypass action(:create) do
      forbid_if expr(ticket.available_for_customer == 0)
      authorize_if actor_present()
    end

    policy action(:create) do
      authorize_if actor_present()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action(:add_to_basket) do
      authorize_if always()
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

    policy action(:update) do
      authorize_if always()
    end

    policy action([:destroy]) do
      authorize_if expr(customer.user.id == ^actor(:id))
    end
  end

  postgres do
    table "ticket_instances"
    repo Gits.Repo
  end
end

defmodule Gits.Storefront.TicketInstance.Calculations.Address do
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
