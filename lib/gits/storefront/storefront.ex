defmodule Gits.Storefront do
  use Ash.Domain, extensions: [AshPaperTrail.Domain]

  alias Gits.Storefront.{Basket, Customer, Event, Ticket, TicketInstance, TicketInvite}

  paper_trail do
    include_versions? true
  end

  resources do
    resource Basket
    resource Event
    resource Customer
    resource Ticket
    resource TicketInstance
    resource TicketInvite
  end
end
