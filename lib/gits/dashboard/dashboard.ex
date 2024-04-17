defmodule Gits.Dashboard do
  use Ash.Domain

  resources do
    resource Gits.Dashboard.Member
    resource Gits.Dashboard.Account
    resource Gits.Dashboard.Invite
  end
end
