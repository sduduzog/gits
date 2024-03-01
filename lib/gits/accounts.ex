defmodule Gits.Accounts do
  use Ash.Api, extensions: [AshGraphql.Api]

  resources do
    resource Gits.Accounts.User
    resource Gits.Accounts.Token
    resource Gits.Accounts.Profile
  end

  graphql do
    authorize? false
  end
end
