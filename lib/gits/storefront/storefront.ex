defmodule Gits.Storefront do
  use Ash.Domain

  alias __MODULE__.{
    Event,
    EventDetails,
    EventMedia,
    EventSchedule,
    Interaction,
    Order,
    TicketType
  }

  resources do
    resource Order
    resource Event
    resource EventDetails
    resource EventMedia
    resource EventSchedule
    resource Interaction
    resource TicketType
  end
end
