defmodule Gits.Dashboard do
  use Ash.Domain
  alias Gits.Dashboard

  resources do
    resource Dashboard.Member

    resource Dashboard.Account do
      define :create_account, args: [:name], action: :create
    end

    resource Dashboard.Invite
  end
end
