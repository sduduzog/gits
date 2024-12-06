defmodule Gits.Storefront do
  use Ash.Domain, extensions: [AshPaperTrail.Domain]

  alias __MODULE__.{
    Event,
    Interaction,
    Order,
    OrderFeesSplit,
    Ticket,
    TicketType
  }

  resources do
    resource Event
    resource Event.Version
    resource Interaction
    resource Order
    resource OrderFeesSplit
    resource Ticket
    resource Ticket.Version
    resource TicketType
    resource TicketType.Version
  end
end
