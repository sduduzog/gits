defmodule Gits.Accounts do
  use Ash.Domain
  alias Gits.Accounts.{Host, Role, Token, User, UserIdentity}

  resources do
    resource Host
    resource Role
    resource Token
    resource User
    resource UserIdentity
  end
end
