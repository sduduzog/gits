defmodule Gits.Accounts.Invite do
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
      constraints one_of: [:pending, :accepted, :rejected]

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
    defaults [:read, :update]

    create :create do
      argument :account, :map, allow_nil?: false

      change manage_relationship(:account, type: :append)
    end
  end

  policies do
    policy action(:create) do
      authorize_if Gits.Checks.CanInviteUser
    end
  end

  postgres do
    table "account_invites"
    repo Gits.Repo
  end
end
