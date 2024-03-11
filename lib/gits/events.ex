defmodule Gits.Events do
  use Ash.Api

  resources do
    resource Gits.Events.Event
    resource Gits.Events.Ticket
    resource Gits.Events.TicketInstance
    resource Gits.Events.Cart
    resource Gits.Events.CartPayment
  end
end
