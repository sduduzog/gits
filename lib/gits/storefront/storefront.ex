defmodule Gits.Storefront do
  use Ash.Domain

  resources do
    resource Gits.Storefront.Event
    resource Gits.Storefront.Ticket
  end
end
