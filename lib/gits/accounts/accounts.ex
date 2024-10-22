defmodule Gits.Accounts do
  use Ash.Domain
  alias Gits.Accounts.{Token, User}

  resources do
    resource User
    resource Token
  end
end
