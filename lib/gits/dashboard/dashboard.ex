defmodule Gits.Dashboard do
  use Ash.Domain
  alias Gits.Dashboard
  alias Gits.Dashboard.Venue

  resources do
    resource Dashboard.Member

    resource Dashboard.Account do
      define :create_account, args: [:name], action: :create
    end

    resource Dashboard.BillingSettings

    resource Dashboard.Invite

    resource Dashboard.Venue do
      define :save_venue_for_event,
        args: [:place_id, :name, :google_maps_uri, :formatted_address, :type, :event],
        action: :create
    end

    resource Venue.DetailedGoogleAddress do
      define :fetch_address_from_api, args: [:id], action: :fetch_from_api, get?: true
    end

    resource Venue.GoogleAddress do
      define :search_for_address, args: [:query], action: :search
    end
  end
end
