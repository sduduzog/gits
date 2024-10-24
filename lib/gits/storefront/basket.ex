defmodule Gits.Storefront.Basket do
  require Ash.Query

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine, AshPaperTrail.Resource],
    domain: Gits.Storefront,
    notifiers: [Ash.Notifier.PubSub]

  require Ash.Resource.Change.Builtins
  alias Gits.Storefront.Calculations.SumOfInstancePrices
  alias Gits.Storefront.Notifiers.{BasketCancelled, BasketOpened, BasketReclaimed}
  alias Gits.Storefront.TicketInstance

  postgres do
    table "baskets"
    repo Gits.Repo
  end

  state_machine do
    initial_states [:open, :invited]
    default_initial_state :open

    transitions do
      transition :settle_for_free, from: :open, to: :settled_for_free
      transition :start_payment, from: :open, to: :payment_started
      transition :evaluate_paystack_transaction, from: :payment_started, to: :settled_for_payment
      transition :cancel, from: [:open, :payment_started], to: :cancelled
      transition :reclaim, from: [:open, :payment_started], to: :reclaimed
    end
  end

  paper_trail do
    reference_source? false
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  actions do
    read :read do
      primary? true
    end

    create :open_basket do
      argument :event, :map, allow_nil?: false
      argument :customer, :map, allow_nil?: false

      change manage_relationship(:event, type: :append)
      change manage_relationship(:customer, type: :append)

      notifiers [BasketOpened]
    end

    create :accept_invite do
      argument :ticket, :map do
        allow_nil? false
      end

      argument :customer, :map do
        allow_nil? false
      end

      change set_attribute(:state, :invited)

      change fn changeset, %{actor: actor} ->
        changeset
        |> Ash.Changeset.after_action(fn changeset, record ->
          ticket = changeset |> Ash.Changeset.get_argument(:ticket)
          customer = changeset |> Ash.Changeset.get_argument(:customer)

          ticket
          |> Ash.Changeset.for_update(
            :add_invite_instance,
            %{
              basket: record,
              customer: changeset.data.customer
            },
            actor: actor
          )
          |> Ash.update!()

          {:ok, record}
        end)
      end
    end

    update :add_ticket do
      require_atomic? false

      argument :ticket_id, :uuid do
        allow_nil? false
      end

      change fn changeset, %{actor: actor} ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          ticket_id =
            changeset
            |> Ash.Changeset.get_argument(:ticket_id)

          changeset.data.event.tickets
          |> Enum.find(fn ticket -> ticket.id == ticket_id end)
          |> Ash.Changeset.for_update(
            :add_instance,
            %{
              basket: changeset.data,
              customer: changeset.data.customer
            },
            actor: actor
          )
          |> Ash.update()

          changeset
        end)
      end
    end

    update :remove_ticket do
      require_atomic? false

      argument :ticket_id, :uuid do
        allow_nil? false
      end

      change fn changeset, %{actor: actor} ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          ticket_id = changeset |> Ash.Changeset.get_argument(:ticket_id)

          instance =
            changeset.data.instances
            |> Enum.find(fn instance -> instance.ticket_id == ticket_id end)

          case instance do
            nil ->
              changeset

            %TicketInstance{} ->
              changeset.data.event.tickets
              |> Enum.find(fn ticket -> ticket.id == ticket_id end)
              |> Ash.Changeset.for_update(:remove_instance, %{
                id: instance.id
              })
              |> Ash.update(actor: actor)

              changeset
          end
        end)
      end
    end

    update :start_payment do
      require_atomic? false

      change Gits.Storefront.Changes.SetPaymentMethodToBasket

      change transition_state(:payment_started)
    end

    update :cancel do
      require_atomic? false

      change fn changeset, %{actor: actor} ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          changeset.data
          |> Ash.load([:instances], actor: actor)
          |> case do
            {:ok, basket} ->
              changeset
              |> Ash.Changeset.manage_relationship(
                :instances,
                basket.instances,
                on_match: {:update, :cancel}
              )

            _ ->
              changeset
          end
        end)
      end

      change transition_state(:cancelled)

      notifiers [BasketCancelled]
    end

    update :settle_for_free do
      require_atomic? false

      change fn changeset, %{actor: actor} ->
        instances =
          changeset.data
          |> Ash.load!(:instances, actor: actor)
          |> Map.get(:instances)

        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          changeset
          |> Ash.Changeset.manage_relationship(
            :instances,
            Enum.map(instances, & &1.id),
            on_match: {:update, :prepare_for_use}
          )
        end)
      end

      change transition_state(:settled_for_free)
    end

    update :start_paystack_transaction do
      require_atomic? false
      change Gits.Storefront.Changes.StartPaystackTransaction
    end

    update :evaluate_paystack_transaction do
      require_atomic? false

      change Gits.Storefront.Changes.EvaluatePaystackTransaction
    end

    update :refund do
      transition_state(:refunded)
    end

    update :reclaim do
      require_atomic? false

      change fn changeset, %{actor: actor} ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          changeset.data
          |> Ash.load([:instances], actor: actor)
          |> case do
            {:ok, basket} ->
              changeset
              |> Ash.Changeset.manage_relationship(
                :instances,
                basket.instances,
                on_match: {:update, :reclaim}
              )

            _ ->
              changeset
          end
        end)
      end

      change transition_state(:reclaimed)

      notifiers [BasketReclaimed]
    end
  end

  policies do
    policy action(:read) do
      authorize_if Gits.Checks.ActorIsObanJob
      authorize_if expr(customer.user.id == ^actor(:id))
      authorize_if actor_present()
    end

    policy action(:add_ticket) do
      authorize_if actor_present()
    end

    policy action(:remove_ticket) do
      authorize_if actor_present()
    end

    policy action(:start_paystack_transaction) do
      authorize_if expr(state == :payment_started)
    end

    policy action(:start_paystack_transaction) do
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:evaluate_paystack_transaction) do
      authorize_if expr(not is_nil(paystack_reference))
    end

    policy action(:settle_for_free) do
      authorize_if expr(exists(instances, ticket.price == 0))
    end

    policy action(:settle_for_free) do
      authorize_if expr(count(instances) > 0)
    end

    policy action(:settle_for_free) do
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:start_payment) do
      authorize_if expr(not is_nil(event.account.paystack_subaccount_code))
    end

    policy action(:lock_for_checkout) do
      forbid_unless expr(count(instances) > 0)
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:unlock_for_shopping) do
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:read_for_shopping) do
      forbid_unless expr(state == :open)
      forbid_unless expr(customer.user.id == ^actor(:id))
      authorize_if actor_present()
    end

    policy action(:read_for_checkout) do
      forbid_unless expr(state in [:settled_for_free])
      forbid_unless expr(customer.user.id == ^actor(:id))
      authorize_if actor_present()
    end

    policy action(:read_for_checkout_summary) do
      forbid_unless expr(state == :locked_for_checkout)
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:add_ticket_to_basket) do
      authorize_if actor_present()
    end

    policy action(:cancel) do
      forbid_unless expr(customer.user.id == ^actor(:id))
      forbid_unless expr(state in [:open, :payment_started])
      authorize_if actor_present()
    end

    policy action(:reclaim) do
      forbid_unless expr(state in [:open, :payment_started])
      authorize_if Gits.Checks.ActorIsObanJob
    end

    policy action([
             :open_basket,
             :accept_invite,
             :lock_for_checkout,
             :unlock_for_shopping
           ]) do
      authorize_if actor_present()
    end
  end

  pub_sub do
    module GitsWeb.Endpoint
    prefix "basket"
    publish :cancel, ["cancelled", :id]
    publish :reclaimed, ["reclaimed", :id]
  end

  attributes do
    uuid_primary_key :id

    attribute :payment_method, :atom do
      public? true
      constraints one_of: [:paystack, :payfast]
    end

    attribute :paystack_authorization_url, :string
    attribute :paystack_reference, :string

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
    end

    belongs_to :customer, Gits.Storefront.Customer

    has_many :instances, Gits.Storefront.TicketInstance
  end

  calculations do
    calculate :event_name, :string, expr(event.name)
    calculate :total, :decimal, SumOfInstancePrices
  end
end
