defmodule Gits.Storefront.Order do
  require Decimal

  alias Gits.PaystackApi
  alias Gits.Storefront.{Event, OrderFeesSplit, Ticket, TicketType}

  alias __MODULE__.Notifiers.{
    OrderCancelled,
    OrderCompleted,
    OrderConfirmed,
    OrderCreated,
    OrderRefunded,
    OrderRefundRequested
  }

  alias __MODULE__.Checks.OrderUserLimitReached

  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshStateMachine, AshPaperTrail.Resource]

  postgres do
    table "orders"
    repo Gits.Repo
  end

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

      transition :cancel, from: [:anonymous, :open, :processed, :confirmed], to: :cancelled
    end
  end

  paper_trail do
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
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

      notifiers [OrderCreated]
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
          changeset
          |> AshStateMachine.transition_state(:completed)
          |> Ash.Changeset.atomic_update(:completed_at, expr(fragment("now()")))
        end
      end

      notifiers [OrderConfirmed, OrderCompleted]
    end

    update :complete do
      require_atomic? false

      argument :fees_split, :map, allow_nil?: false

      change manage_relationship(:fees_split, type: :create)
      change transition_state(:completed)
      change atomic_update(:completed_at, expr(fragment("now()")))

      notifiers [OrderCompleted]
    end

    update :request_refund do
      change set_attribute(:requested_refund_secret, &NimbleTOTP.secret/0)
      change atomic_update(:requested_refund_at, expr(fragment("now()")))

      notifiers [OrderRefundRequested]
    end

    update :cancel do
      require_atomic? false

      argument :reason, :string, allow_nil?: false

      change atomic_update(:cancelled_at, expr(fragment("now()")))
      change transition_state(:cancelled)

      change fn changeset, %{actor: actor} ->
        reason = Ash.Changeset.get_argument(changeset, :reason)

        Ash.Changeset.change_attribute(changeset, :cancellation_reason, reason)
        |> Ash.Changeset.before_action(fn changeset ->
          order =
            Ash.reload!(changeset.data, load: [:tickets], actor: actor)

          Ash.Changeset.manage_relationship(changeset, :tickets, order.tickets,
            on_match: {:update, :release}
          )
        end)
      end

      notifiers [OrderCancelled]
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
      authorize_unless OrderUserLimitReached
    end

    policy action(:remove_ticket) do
      authorize_if always()
    end

    policy action(:process) do
      authorize_if expr(has_tickets?)
    end

    policy action(:request_refund) do
      authorize_if always()
    end

    policy action([:open, :process, :reopen, :confirm, :complete, :refund, :cancel]) do
      authorize_if AshStateMachine.Checks.ValidNextState
    end

    policy action(:cancel) do
      authorize_if actor_attribute_equals(
                     :worker,
                     to_string(OrderCreated) |> String.replace("Elixir.", "")
                   )
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

    attribute :cancelled_at, :utc_datetime_usec
    attribute :cancellation_reason, :string, public?: true
    attribute :completed_at, :utc_datetime_usec

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

    calculate :has_tickets?, :boolean, expr(count(tickets, query: [filter: expr(true)]) > 0)
  end
end
