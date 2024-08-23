defmodule Gits.Auth do
  use Ash.Domain

  resources do
    resource Gits.Auth.User
    resource Gits.Auth.Token
    resource Gits.Auth.UserIdentity
  end
end
