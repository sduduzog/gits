defmodule Gits.Accounts do
  use Ash.Domain

  resources do
    resource Gits.Accounts.Account
    resource Gits.Accounts.Role
    resource Gits.Accounts.User
    resource Gits.Accounts.Token
    resource Gits.Accounts.Invite
  end
end
