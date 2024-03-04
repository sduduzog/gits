defmodule Gits.Accounts.Role do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    attribute :type, :atom do
      constraints one_of: [:owner]

      default :owner

      allow_nil? false
    end
  end

  postgres do
    table "account_roles"
    repo Gits.Repo
  end

  relationships do
    belongs_to :user, Gits.Accounts.User, primary_key?: true, allow_nil?: false
    belongs_to :account, Gits.Accounts.Account, primary_key?: true, allow_nil?: false
  end
end
