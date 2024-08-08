defmodule Gits.Storefront do
  use Ash.Domain, extensions: [AshPaperTrail.Domain]

  paper_trail do
    include_versions? true
  end

  resources do
    resource Gits.Storefront.Event
    resource Gits.Storefront.Customer
    resource Gits.Storefront.Ticket
    resource Gits.Storefront.TicketInstance
    resource Gits.Storefront.Basket
  end
end
