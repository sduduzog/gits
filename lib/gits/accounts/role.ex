defmodule Gits.Accounts.Role do
  use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshArchival.Resource], domain: Gits.Accounts

  attributes do
    attribute :type, :atom do
      constraints one_of: [:owner, :admin, :access_coordinator]

      default :owner

      allow_nil? false
    end

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  actions do
    defaults [:create]
  end

  postgres do
    table "account_roles"
    repo Gits.Repo
  end

  relationships do
    belongs_to :user, Gits.Accounts.User,
      attribute_writable?: true,
      primary_key?: true,
      allow_nil?: false

    belongs_to :account, Gits.Accounts.Account,
      attribute_writable?: true,
      primary_key?: true,
      allow_nil?: false
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end
end
