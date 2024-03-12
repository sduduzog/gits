defmodule Gits.Accounts.Role do
  use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshArchival.Resource]

  attributes do
    attribute :type, :atom do
      constraints one_of: [:owner]

      default :owner

      allow_nil? false
    end

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
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
