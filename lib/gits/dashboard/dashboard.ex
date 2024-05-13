defmodule Gits.Dashboard do
  use Ash.Domain

  resources do
    resource Gits.Dashboard.Member
    resource Gits.Dashboard.Account
    resource Gits.Dashboard.Invite
    resource Gits.Dashboard.Venue

    resource Gits.Dashboard.Venue.GoogleAddress do
      define :search_for_address, args: [:query], action: :search
    end
  end
end
