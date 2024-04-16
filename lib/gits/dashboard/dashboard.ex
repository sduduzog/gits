defmodule Gits.Dashboard do
  use Ash.Domain

  resources do
    resource Gits.Dashboard.Member
    resource Gits.Dashboard.Account
  end
end
