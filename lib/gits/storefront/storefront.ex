defmodule Gits.Storefront do
  use Ash.Domain

  alias __MODULE__.{
    Event,
    EventMedia,
    EventSchedule,
    Interaction,
    Order,
    Ticket,
    TicketType
  }

  resources do
    resource Order
    resource Event
    resource EventMedia
    resource EventSchedule
    resource Interaction
    resource Ticket
    resource TicketType
  end
end
