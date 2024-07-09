defmodule Gits.Storefront do
  use Ash.Domain

  resources do
    resource Gits.Storefront.Event
    resource Gits.Storefront.Customer
    resource Gits.Storefront.Ticket
    resource Gits.Storefront.TicketInstance
    resource Gits.Storefront.Basket
    resource Gits.Storefront.Keypair
  end
end
