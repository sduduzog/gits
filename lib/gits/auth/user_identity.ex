defmodule Gits.Auth.UserIdentity do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.UserIdentity],
    domain: Gits.Auth

  postgres do
    table "user_identities"
    repo Gits.Repo
  end

  user_identity do
    user_resource Gits.Auth.User
  end
end
