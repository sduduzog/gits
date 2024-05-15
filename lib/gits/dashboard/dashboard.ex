defmodule Gits.Dashboard do
  use Ash.Domain

  resources do
    resource Gits.Dashboard.Member
    resource Gits.Dashboard.Account
    resource Gits.Dashboard.Invite

    resource Gits.Dashboard.Venue

    resource Gits.Dashboard.Venue.DetailedGoogleAddress do
      define :fetch_address_from_api, args: [:id], action: :fetch_from_api, get?: true
    end

    resource Gits.Dashboard.Venue.GoogleAddress do
      define :search_for_address, args: [:query], action: :search
    end
  end
end
