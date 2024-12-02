defmodule Gits.Accounts.UserIdentity do
  alias Gits.Accounts.User
  alias Gits.Repo

  use Ash.Resource,
    domain: Gits.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.UserIdentity]

  postgres do
    table "user_identities"
    repo Repo
  end

  user_identity do
    user_resource User
  end
end
