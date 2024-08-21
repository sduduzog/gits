defmodule Gits.Storefront.TicketInvite do
  require Ash.Query

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine, AshArchival.Resource],
    domain: Gits.Storefront

  require Ash.Resource.Change.Builtins
  require Ash.Resource.Change.Builtins
  alias Gits.Storefront.Notifiers.InviteCreated
  alias Gits.Storefront.{Basket, Customer, Ticket}

  postgres do
    table "ticket_invites"
    repo Gits.Repo
  end

  state_machine do
    initial_states [:created]
    default_initial_state :created

    transitions do
      transition :accept, from: :created, to: :accepted
    end
  end

  actions do
    default_accept :*
    defaults [:read, :destroy]

    create :create do
      argument :customer, :map do
        allow_nil? false
      end

      argument :ticket, :map do
        allow_nil? false
      end

      change manage_relationship(:customer, type: :append)
      change manage_relationship(:ticket, type: :append)
    end

    create :email_only do
      accept [:receipient_email]

      argument :ticket, :map do
        allow_nil? false
      end

      change manage_relationship(:ticket, type: :append)

      notifiers [InviteCreated]
    end

    update :accept do
      require_atomic? false

      change before_action(fn changeset, %{actor: actor} ->
               invite =
                 changeset.data |> Ash.load!([:customer, ticket: :event], actor: actor)

               customer =
                 if is_nil(invite.customer) do
                   Customer
                   |> Ash.Changeset.for_create(:create, %{user: actor}, actor: actor)
                   |> Ash.create!()
                 else
                   invite.customer
                 end

               basket =
                 Basket
                 |> Ash.Changeset.for_create(
                   :accept_invite,
                   %{
                     customer: customer,
                     ticket: invite.ticket
                   },
                   actor: actor
                 )
                 |> Ash.create!()

               changeset
             end)

      change transition_state(:accepted)
    end
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end

    policy action(:accept) do
      authorize_if expr(receipient_email == ^actor(:email))
      authorize_if expr(customer.user.id == ^actor(:id))
    end

    policy action([:create, :email_only]) do
      authorize_if actor_present()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :receipient_email, :ci_string, public?: true

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :ticket, Ticket
    belongs_to :customer, Customer
  end

  identities do
    identity :email_ticket_invite, [:receipient_email, :ticket_id]
    identity :customer_ticket_invite, [:customer_id, :ticket_id]
  end
end
