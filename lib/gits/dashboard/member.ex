defmodule Gits.Dashboard.Member do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshArchival.Resource, AshStateMachine],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id

    attribute :role, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:owner, :admin, :access_coordinator]
      default :owner
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  state_machine do
    initial_states [:active, :waitlisted]
    default_initial_state :active
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account

    belongs_to :user, Gits.Auth.User do
      domain Gits.Auth
    end

    has_one :invite, Gits.Dashboard.Invite
  end

  calculations do
    calculate :waitlisted, :boolean, expr(state == :waitlisted)
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      accept :*

      argument :user, :map

      change manage_relationship(:user, type: :append)
    end

    create :accept_invitation do
      argument :account, :map do
        allow_nil? false
      end

      argument :user, :map do
        allow_nil? false
      end

      argument :invite, :map do
        allow_nil? false
      end

      change before_action(fn changeset, _ ->
               invite =
                 Ash.Changeset.get_argument(changeset, :invite)

               Ash.Changeset.change_attribute(changeset, :role, invite.role)
             end)

      change manage_relationship(:account, type: :append)
      change manage_relationship(:user, type: :append)
      change manage_relationship(:invite, on_lookup: {:relate_and_update, :accept})
    end

    create :waitlist do
      argument :user, :map

      change set_attribute(:state, :waitlisted)
      change manage_relationship(:user, type: :append)
    end
  end

  policies do
    policy action(:read) do
      authorize_if expr(
                     exists(
                       account,
                       members.id == ^actor(:id) and members.role in [:owner, :admin]
                     )
                   )

      authorize_if expr(user.id == ^actor(:id))
    end

    policy action(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if always()
    end

    policy always() do
      authorize_if actor_present()
    end
  end

  postgres do
    table "members"
    repo Gits.Repo
  end

  identities do
    identity :account_member, [:user_id, :account_id] do
      eager_check_with Gits.Dashboard
    end
  end
end
