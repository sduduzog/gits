defmodule Gits.Accounts do
  use Ash.Domain
  alias Gits.Accounts.{Host, Role, Token, User}

  resources do
    resource Host
    resource Role
    resource User
    resource Token
  end
end
