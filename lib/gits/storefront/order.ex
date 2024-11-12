defmodule Gits.Storefront.Order do
  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource, AshStateMachine]

  alias Gits.Storefront.{Event, Ticket, TicketType}
  alias __MODULE__.Changes.InitialState

  postgres do
    table "orders"
    repo Gits.Repo
  end

  state_machine do
    initial_states [:anonymous, :open]
    default_initial_state :anonymous

    transitions do
      transition :open, from: :anonymous, to: :open
    end
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:email]

      change InitialState
    end

    update :open do
      accept [:email]

      change transition_state(:open)
    end

    update :process do
    end

    update :confirm do
    end

    update :complete do
    end

    update :refund do
    end

    update :add_ticket do
      argument :ticket_type, :map
      change manage_relationship(:ticket_type, :ticket_types, on_match: {:update, :add_ticket})
    end
  end

  validations do
    validate match(:email, ~r/(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$)/) do
      message "must be a valid email address"
      where [changing(:email)]
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

    has_many :tickets, Ticket

    many_to_many :ticket_types, TicketType do
      through Event
      source_attribute :event_id
      destination_attribute :event_id
      source_attribute_on_join_resource :id
      destination_attribute_on_join_resource :id
    end
  end
end
