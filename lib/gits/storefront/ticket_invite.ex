defmodule Gits.Storefront.TicketInvite do
  require Ash.Query

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine, AshArchival.Resource],
    domain: Gits.Storefront

  alias Gits.Storefront.{Customer, Ticket}

  attributes do
    uuid_primary_key :id

    attribute :receipient_email, :ci_string, public?: true

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  state_machine do
    initial_states [:created]
    default_initial_state :created
  end

  relationships do
    belongs_to :ticket, Ticket
    belongs_to :customer, Customer
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
  end

  identities do
    identity :email_ticket_invite, [:receipient_email, :ticket_id]
    identity :customer_ticket_invite, [:customer_id, :ticket_id]
  end

  policies do
    policy action(:read) do
      authorize_if accessing_from(Ticket, :invites)
    end

    policy action(:create) do
      authorize_if actor_present()
    end
  end

  postgres do
    table "ticket_invites"
    repo Gits.Repo
  end
end
