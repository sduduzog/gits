defmodule Gits.Storefront do
  use Ash.Domain

  alias __MODULE__.{
    Event,
    EventMedia,
    EventSchedule,
    Interaction,
    Order,
    TicketType
  }

  resources do
    resource Order
    resource Event
    resource EventMedia
    resource EventSchedule
    resource Interaction
    resource TicketType
  end
end
