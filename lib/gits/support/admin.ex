defmodule Gits.Support.Admin do
  alias Gits.Accounts
  alias Gits.Accounts.User
  alias Gits.Support
  use Ash.Resource, domain: Support, data_layer: AshPostgres.DataLayer

  postgres do
    table "support_admins"
    repo Gits.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :user, User, domain: Accounts
  end
end
