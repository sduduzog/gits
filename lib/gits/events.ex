defmodule Gits.Events do
  use Ash.Api

  resources do
    resource Gits.Events.Event
    resource Gits.Events.Ticket
    resource Gits.Events.TicketInstance
  end
end