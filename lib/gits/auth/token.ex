defmodule Gits.Auth.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource],
    domain: Gits.Auth

  postgres do
    table "tokens"
    repo Gits.Repo
  end
end
