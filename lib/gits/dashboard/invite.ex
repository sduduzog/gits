defmodule Gits.Dashboard.Invite do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshArchival.Resource, AshStateMachine],
    domain: Gits.Dashboard

  alias Gits.Dashboard.Member

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false, public?: true

    attribute :role, :atom do
      constraints one_of: [:admin, :sales_manager, :attendee_support]
      allow_nil? false
      public? true
    end

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account
    belongs_to :member, Gits.Dashboard.Member

    belongs_to :user, Gits.Auth.User do
      domain Gits.Auth
      define_attribute? false
      source_attribute :email
      destination_attribute :email
    end
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
    defaults [:update, :destroy]

    read :read do
      primary? true

      prepare build(load: [:account])
    end

    read :read_for_recipient do
      argument :id, :uuid do
        allow_nil? false
      end

      filter expr(id == ^arg(:id))

      prepare build(load: [:account])
    end

    read :read_for_dashboard do
      filter expr(state == :sent)
    end

    create :create do
      accept [:email, :role]

      argument :account, :map do
        allow_nil? false
      end

      validate match(:email, ~r/(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$)/) do
        message "must be a valid email address"
        where [changing(:email)]
      end

      change manage_relationship(:account, type: :append)
      change {Gits.Dashboard.Changes.SendDashboardInvite, []}
    end

    update :resend do
      require_atomic? false
      change {Gits.Dashboard.Changes.SendDashboardInvite, []}
    end

    update :accept do
      require_atomic? false
      change transition_state(:accepted)
    end

    update :reject do
      change transition_state(:rejected)
    end

    update :cancel do
      change transition_state(:cancelled)
    end
  end

  policies do
    policy action(:read) do
      authorize_if expr(user.id == ^actor(:id))

      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )
    end

    policy action(:resend) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )

      authorize_if actor_present()
    end

    policy action(:cancel) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )
    end

    policy action(:read_for_dashboard) do
      authorize_if expr(account.members.user.id == ^actor(:id))
    end

    policy action(:read_for_recipient) do
      authorize_if expr(user.id == ^actor(:id))
    end

    policy [action(:accept), accessing_from(Member, :invite)] do
      authorize_if AshStateMachine.Checks.ValidNextState
    end

    policy action_type([:create, :destroy]) do
      authorize_if AshStateMachine.Checks.ValidNextState
    end

    # policy action(:create) do
    #   authorize_if expr(
    #                  account.members.user.id == ^actor(:id) and
    #                    not is_nil(account.members.user.confirmed_at)
    #                )
    # end
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
