defmodule Gits.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api Gits.Accounts
  end

  postgres do
    table "tokens"
    repo Gits.Repo
  end
end
