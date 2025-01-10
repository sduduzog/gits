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
    initial_states [:ready]
    default_initial_state :ready

    transitions do
      transition :admit, from: [:ready], to: :admitted
      transition :release, from: :ready, to: :released
    end
  end

  alias Gits.Storefront.{Order, TicketType}

  paper_trail do
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

    update :rsvp do
      require_atomic? false

      argument :attendee, :map, allow_nil?: false

      change atomic_update(:rsvp_confirmed_at, expr(fragment("now()")))
      change manage_relationship(:attendee, type: :append)
    end

    update :admit do
      change atomic_update(:admitted_at, expr(fragment("now()")))
      change transition_state(:admitted)
    end

    update :release do
      change transition_state(:released)
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

    policy action(:release) do
      authorize_if always()
    end

    policy action(:admit) do
      authorize_if AshStateMachine.Checks.ValidNextState
    end

    policy action(:admit) do
      authorize_if expr(ticket_type.event.host.roles.user.id == ^actor(:id))
    end

    policy action(:rsvp) do
      authorize_if expr(state == :ready)
    end

    policy action(:rsvp) do
      authorize_if expr(is_nil(rsvp_confirmed_at))
    end

    policy action(:rsvp) do
      authorize_if actor_present()
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

    attribute :rsvp_confirmed_at, :utc_datetime, public?: true

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

    calculate :local_admitted_at,
              :naive_datetime,
              expr(
                fragment(
                  "? at time zone 'UTC' at time zone ?",
                  admitted_at,
                  "Africa/Johannesburg"
                )
              )
  end
end
