defmodule Gits.Hosts do
  use Ash.Domain

  alias __MODULE__.{
    Host,
    Role,
    Venue,
    Event,
    EventDetails,
    EventMedia,
    EventSchedule,
    PayoutAccount,
    TicketType
  }

  resources do
    resource Host
    resource Role
    resource Venue
    resource Event
    resource EventDetails
    resource EventMedia
    resource EventSchedule
    resource PayoutAccount
    resource TicketType
  end
end
