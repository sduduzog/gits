defmodule Gits.Storefront.Order do
  require Decimal

  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshStateMachine]

  postgres do
    table "orders"
    repo Gits.Repo
  end

  alias Gits.PaystackApi

  alias Gits.Storefront.{Event, OrderFeesSplit, Ticket, TicketType}
  alias __MODULE__.Notifiers.{OrderCompleted, OrderConfirmed, OrderRefunded, OrderRefundRequested}

  state_machine do
    initial_states [:open, :anonymous]
    default_initial_state :anonymous

    transitions do
      transition :open, from: :anonymous, to: :open
      transition :process, from: :open, to: :processed
      transition :reopen, from: :processed, to: :open
      transition :confirm, from: :processed, to: [:confirmed, :completed]
      transition :complete, from: :confirmed, to: :completed
      transition :refund, from: :completed, to: :refunded
    end
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [:email]

      change fn changeset, _ ->
        if Ash.Changeset.changing_attribute?(changeset, :email) do
          AshStateMachine.transition_state(changeset, :open)
        else
          changeset
        end
      end
    end

    update :open do
      argument :email, :ci_string, allow_nil?: false
      change set_attribute(:email, arg(:email))

      change transition_state(:open)
    end

    update :process do
      accept [:total]
      change transition_state(:processed)
    end

    update :reopen do
      change set_attribute(:total, nil)
      change transition_state(:open)
    end

    update :confirm do
      require_atomic? false

      change fn changeset, _ ->
        if changeset.data.total |> Decimal.gt?(Decimal.new("0")) do
          changeset
          |> AshStateMachine.transition_state(:confirmed)
          |> Ash.Changeset.before_action(fn changeset ->
            order =
              Ash.load!(changeset.data, event: :host)

            code = order.event.host.paystack_subaccount_code

            email = order.email

            price_in_cents = Decimal.mult(order.total, 100) |> Decimal.to_integer()

            {:ok, %{reference: reference, authorization_url: authorization_url}} =
              PaystackApi.create_transaction(code, email, price_in_cents)

            changeset
            |> Ash.Changeset.force_change_new_attribute(:paystack_reference, reference)
            |> Ash.Changeset.force_change_new_attribute(
              :paystack_authorization_url,
              authorization_url
            )
          end)
        else
          changeset |> AshStateMachine.transition_state(:completed)
        end
      end

      notifiers [OrderConfirmed, OrderCompleted]
    end

    update :complete do
      require_atomic? false

      argument :fees_split, :map, allow_nil?: false

      change manage_relationship(:fees_split, type: :create)
      change transition_state(:completed)

      notifiers [OrderCompleted]
    end

    update :request_refund do
      change set_attribute(:requested_refund_secret, &NimbleTOTP.secret/0)
      change atomic_update(:requested_refund_at, expr(fragment("now()")))

      notifiers [OrderRefundRequested]
    end

    update :refund do
      require_atomic? false
      argument :otp, :string, allow_nil?: false

      change fn changeset, %{actor: actor} ->
        Ash.Changeset.before_action(changeset, fn changeset ->
          order =
            Ash.reload!(changeset.data, load: [:tickets], actor: actor)

          secret =
            order.requested_refund_secret

          otp =
            Ash.Changeset.get_argument(changeset, :otp)

          if NimbleTOTP.valid?(secret, otp, period: 60 * 30) do
            AshStateMachine.transition_state(changeset, :refunded)
            |> Ash.Changeset.manage_relationship(:tickets, order.tickets,
              on_match: {:update, :release}
            )
          else
            changeset
          end
        end)
      end

      notifiers [OrderRefunded]
    end

    update :add_ticket do
      require_atomic? false

      argument :ticket_type, :map, allow_nil?: false

      change manage_relationship(:ticket_type, :ticket_types, on_match: {:update, :add_ticket})
    end

    update :remove_ticket do
      require_atomic? false

      argument :ticket_type, :map, allow_nil?: false

      change manage_relationship(:ticket_type, :ticket_types, on_match: {:update, :remove_ticket})
    end
  end

  policies do
    policy action(:create) do
      authorize_if accessing_from(Event, :orders)
    end

    policy action(:read) do
      authorize_if always()
    end

    policy action(:add_ticket) do
      authorize_if always()
    end

    policy action(:remove_ticket) do
      authorize_if always()
    end

    policy action(:process) do
      authorize_if expr(exists(tickets, true))
    end

    policy action(:request_refund) do
      authorize_if always()
    end

    policy action([:open, :process, :reopen, :confirm, :complete, :refund]) do
      authorize_if AshStateMachine.Checks.ValidNextState
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

    attribute :requested_refund_secret, :binary, public?: true
    attribute :requested_refund_at, :utc_datetime_usec

    attribute :paystack_reference, :string, public?: true
    attribute :paystack_authorization_url, :string, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, Event do
      allow_nil? false
    end

    has_many :tickets, Ticket

    has_many :ticket_types, TicketType do
      no_attributes? true
      filter expr(event.id == parent(event.id))
    end

    has_one :fees_split, OrderFeesSplit
  end

  calculations do
    calculate :event_name, :string, expr(event.name)
    calculate :refund_value, :decimal, expr(fees_split.subaccount)
  end
end
