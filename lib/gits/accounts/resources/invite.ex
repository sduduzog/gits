defmodule Gits.Accounts.Invite do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer]

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

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  relationships do
    belongs_to :account, Gits.Accounts.Account
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      argument :account, :map, allow_nil?: false

      change manage_relationship(:account, type: :append)
    end

    update :accept do
      change set_attribute(:status, :accepted)

      change after_action(fn changeset, record ->
               Ash.Changeset.new(Gits.Accounts.Role)
               |> Ash.Changeset.for_create(:create, %{
                 account_id: record.account_id,
                 user_id: changeset.context.actor.id
               })

               {:ok, record}
             end)
    end

    update :reject do
      change set_attribute(:status, :accepted)
    end
  end

  changes do
    change {Gits.Accounts.Invite.Changes.CreateInvite, []},
      where: [action_is(:create)]
  end

  policies do
    policy action(:create) do
      authorize_if Gits.Checks.CanInviteUser
    end

    policy action(:accept) do
      authorize_if Gits.Checks.CanAcceptInvite
    end
  end

  postgres do
    table "account_invites"
    repo Gits.Repo
  end

  identities do
    identity :unique_email_invite, [:email, :account_id] do
      eager_check_with Gits.Accounts
    end
  end
end
