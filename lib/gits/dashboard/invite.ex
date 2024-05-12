defmodule Gits.Dashboard.Invite do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshArchival.Resource, AshStateMachine],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false, public?: true

    attribute :role, :atom do
      constraints one_of: [:admin, :editor, :access_coordinator]
      allow_nil? false
      public? true
    end

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account
  end

  state_machine do
    initial_states [:sent]
    default_initial_state :sent

    transitions do
      transition :accept, from: :sent, to: :accepted
      transition :reject, from: :sent, to: :rejected
      transition :cancel, from: :sent, to: :cancelled
    end
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:email, :role]

      argument :account, :map do
        allow_nil? false
      end

      change manage_relationship(:account, type: :append)
      change {Gits.Dashboard.Changes.SendInviteEmail, []}
    end

    update :accept do
    end

    update :reject do
    end

    update :cancel do
    end
  end

  policies do
    policy always() do
      authorize_if always()
    end

    policy action_type([:create, :update, :destroy]) do
      authorize_if AshStateMachine.Checks.ValidNextState
    end
  end

  postgres do
    table "account_invites"
    repo Gits.Repo
  end

  identities do
    identity :unique_email_invite, [:email, :account_id] do
      eager_check_with Gits.Dashboard
    end
  end
end
