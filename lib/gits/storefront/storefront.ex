defmodule Gits.Storefront do
  use Ash.Domain

  alias __MODULE__.{
    Event,
    EventMedia,
    Interaction,
    Order,
    OrderFeesSplit,
    Ticket,
    TicketType
  }

  resources do
    resource Event
    resource EventMedia
    resource Interaction
    resource Order
    resource OrderFeesSplit
    resource Ticket
    resource TicketType
  end
end
