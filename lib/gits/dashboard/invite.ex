defmodule Gits.Dashboard.Invite do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshArchival.Resource, AshStateMachine],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false

    attribute :role, :atom do
      constraints one_of: [:admin, :editor, :access_coordinator]
      allow_nil? false
    end

    attribute :status, :atom do
      constraints one_of: [:pending, :accepted, :declined]

      default :pending

      allow_nil? false
    end

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  state_machine do
    initial_states [:pending]
    default_initial_state :pending

    transitions do
      transition :accept, from: :pending, to: :accepted
      transition :reject, from: :pending, to: :rejected
      transition :cancel, from: :pending, to: :cancelled
    end
  end

  actions do
    defaults [:read, :update, :destroy, create: :*]

    update :accept do
    end

    update :reject do
    end

    update :cancel do
    end
  end

  policies do
    policy always() do
      authorize_if AshStateMachine.Checks.ValidNextState
    end
  end

  postgres do
    table "account_invites"
    repo Gits.Repo
  end
end
