defmodule Gits.Accounts.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :type, :atom do
      constraints one_of: [:user]

      default :user

      allow_nil? false
    end
  end

  postgres do
    table "accounts"
    repo Gits.Repo
  end

  relationships do
    belongs_to :user, Gits.Accounts.User
  end
end
