defmodule Gits.Accounts.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Accounts

  attributes do
    uuid_primary_key :id

    attribute :type, :atom do
      constraints one_of: [:user]

      default :user

      allow_nil? false
    end

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    has_many :events, Gits.Events.Event do
      domain Gits.Events
    end

    has_many :roles, Gits.Accounts.Role

    has_many :invites, Gits.Accounts.Invite
  end

  actions do
    defaults [:create, :read, :update]
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "accounts"
    repo(Gits.Repo)
  end
end
