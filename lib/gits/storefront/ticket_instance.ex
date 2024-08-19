defmodule Gits.Storefront.TicketInstance do
  require Ash.Query

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine],
    domain: Gits.Storefront

  alias Gits.Storefront.Basket
  alias Gits.Storefront.Calculations.{HolderIdFromToken, QrCode}
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Ticket

  postgres do
    table "ticket_instances"
    repo Gits.Repo
  end

  state_machine do
    initial_states [:reserved]
    default_initial_state :reserved

    transitions do
      transition :prepare_for_use, from: :reserved, to: :ready_for_use
      transition :cancel, from: [:reserved, :locked_for_checkout], to: :cancelled
      transition :reclaim, from: [:reserved, :locked_for_checkout], to: :reclaimed
    end
  end

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    read :qr_code do
      argument :token, :string, allow_nil?: false

      prepare before_action(fn query, _ ->
                token =
                  query
                  |> Ash.Query.get_argument(:token)

                ExBase58.decode(token)
                |> case do
                  {:ok, decoded} ->
                    [id, _] = decoded |> String.split(":")

                    query
                    |> Ash.Query.filter(id: id)

                  {:error, _} ->
                    query |> Ash.Query.add_error("There was an error decoding the token")
                end
              end)
    end

    create :create do
      primary? true
      argument :basket, :map, allow_nil?: false

      change before_action(fn changeset, %{actor: user} ->
               customer =
                 Customer
                 |> Ash.Query.for_read(:read, %{}, actor: user)
                 |> Ash.Query.filter(user.id == ^user.id)
                 |> Ash.read_one!()

               changeset |> Ash.Changeset.manage_relationship(:customer, customer, type: :append)
             end)

      change manage_relationship(:basket, type: :append)
    end

    create :create_for_invite do
      argument :basket, :map, allow_nil?: false

      change set_attribute(:state, :ready_for_use)

      change before_action(fn changeset, %{actor: user} ->
               customer =
                 Customer
                 |> Ash.Query.for_read(:read, %{}, actor: user)
                 |> Ash.Query.filter(user.id == ^user.id)
                 |> Ash.read_one!()

               changeset |> Ash.Changeset.manage_relationship(:customer, customer, type: :append)
             end)

      change manage_relationship(:basket, type: :append)
    end

    update :cancel do
      require_atomic? false

      change transition_state(:cancelled)
    end

    update :prepare_for_use do
      require_atomic? false
      change transition_state(:ready_for_use)
    end

    update :reclaim do
      require_atomic? false

      change transition_state(:reclaimed)
    end
  end

  policies do
    policy action(:qr_code) do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if accessing_from(Basket, :instances)
      authorize_if accessing_from(Ticket, :instances)
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action(:prepare_for_use) do
      authorize_if accessing_from(Basket, :instances)
    end

    policy action([:create, :create_for_invite]) do
      authorize_if accessing_from(Ticket, :instances)
    end

    policy action([:cancel, :reclaim]) do
      authorize_if accessing_from(Basket, :instances)
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

  attributes do
    integer_primary_key :id

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :ticket, Ticket
    belongs_to :customer, Customer
    belongs_to :basket, Basket
  end

  calculations do
    calculate :price, :decimal, expr(ticket.price)
    calculate :event_id, :integer, expr(ticket.event.id)
    calculate :event_name, :string, expr(ticket.event.name)
    calculate :ticket_name, :string, expr(ticket.name)
    calculate :event_starts_at, :naive_datetime, expr(ticket.event.starts_at)

    calculate :ticket_holder_id, :uuid, {HolderIdFromToken, []} do
      argument :token, :string, allow_nil?: false
    end

    calculate :qr_code, :string, QrCode
  end
end
