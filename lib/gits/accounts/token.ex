defmodule Gits.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource],
    domain: Gits.Accounts

  postgres do
    table "tokens"
    repo Gits.Repo
  end
end
