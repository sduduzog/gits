defmodule Gits.Events do
  use Ash.Domain

  resources do
    resource Gits.Events.Event
    resource Gits.Events.Ticket
    resource Gits.Events.TicketInstance
    resource Gits.Events.Attendee
  end
end
