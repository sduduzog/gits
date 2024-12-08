defmodule Gits.Storefront.Ticket do
  alias Gits.Accounts.User
  alias Gits.Accounts

  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshStateMachine, AshPaperTrail.Resource]

  postgres do
    table "tickets"
    repo Gits.Repo
  end

  state_machine do
    initial_states [:open]
    default_initial_state :open

    transitions do
      transition :check_in, from: :open, to: :checked_in
      transition :admit, from: [:open, :checked_in], to: :admitted
    end
  end

  alias Gits.Storefront.{Order, TicketType}

  paper_trail do
    belongs_to_actor :user, User, domain: Accounts
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true

      argument :order, :map, allow_nil?: false

      change manage_relationship(:order, type: :append)
    end

    update :check_in do
    end

    update :admit do
    end
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if accessing_from(TicketType, :tickets)
    end

    policy action(:destroy) do
      authorize_if accessing_from(TicketType, :tickets)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :public_id, :string,
      allow_nil?: false,
      writable?: false,
      public?: true,
      default: fn -> Nanoid.generate(6, "0123456789abcdef") end

    attribute :admitted_at, :utc_datetime, public?: true
    attribute :checked_in_at, :utc_datetime, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :attendee, User, domain: Accounts
    belongs_to :order, Order, allow_nil?: false
    belongs_to :ticket_type, TicketType, allow_nil?: false
  end

  calculations do
    calculate :ticket_type_name, :string, expr(ticket_type.name)
  end
end
