defmodule Gits.Accounts do
  use Ash.Api

  resources do
    resource Gits.Accounts.User
    resource Gits.Accounts.Token
  end
end
