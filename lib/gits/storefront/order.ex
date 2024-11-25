defmodule Gits.Storefront.Order do
  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource, AshStateMachine]

  alias Gits.Storefront.{Event, Ticket, TicketType}
  alias __MODULE__.Changes.{ConfirmOrder}
  alias __MODULE__.Notifiers.OrderCompletedEmailNotifier

  postgres do
    table "orders"
    repo Gits.Repo
  end

  state_machine do
    initial_states [:open]
    default_initial_state :open

    transitions do
      transition :process, from: :open, to: :processed
      transition :reopen, from: :processed, to: :open
      transition :confirm, from: :processed, to: [:confirmed, :completed]
      transition :refund, from: :completed, to: :refunded
    end
  end

  actions do
    defaults [:read]

    create :open do
      primary? true
      accept [:email]
    end

    update :process do
      change set_attribute(:total, 0)
      change transition_state(:processed)
    end

    update :reopen do
      change set_attribute(:total, nil)
      change transition_state(:open)
    end

    update :confirm do
      require_atomic? false

      argument :email, :ci_string, allow_nil?: false
      change set_attribute(:email, arg(:email))
      change ConfirmOrder
      notifiers [OrderCompletedEmailNotifier]
    end

    update :complete do
    end

    update :request_refund do
      change atomic_update(:requested_refund_at, expr(fragment("now()")))
    end

    update :refund do
    end

    update :add_ticket do
      require_atomic? false

      argument :ticket, :map, allow_nil?: false

      change manage_relationship(:ticket, :tickets, type: :create)
    end

    update :remove_ticket do
      require_atomic? false

      argument :ticket, :map, allow_nil?: false

      change manage_relationship(:ticket, :tickets, on_match: :destroy)
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

    attribute :number, :integer,
      generated?: true,
      allow_nil?: false,
      writable?: false,
      public?: true

    attribute :email, :ci_string, public?: true
    attribute :total, :decimal, public?: true
    attribute :requested_refund_at, :utc_datetime_usec

    create_timestamp :created_at
    update_timestamp :updated_at
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

  calculations do
    calculate :event_name, :string, expr(event.name)
  end
end
