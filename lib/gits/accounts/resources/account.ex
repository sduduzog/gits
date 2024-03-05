defmodule Gits.Accounts.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    integer_primary_key :id

    attribute :type, :atom do
      constraints one_of: [:user]

      default :user

      allow_nil? false
    end
  end

  actions do
    defaults [:create]
  end

  postgres do
    table "accounts"
    repo Gits.Repo
  end

  relationships do
    has_many :roles, Gits.Accounts.Role
  end
end
