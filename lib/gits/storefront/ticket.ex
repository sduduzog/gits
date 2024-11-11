defmodule Gits.Storefront.Ticket do
  use Ash.Resource, domain: Gits.Storefront, data_layer: AshPostgres.DataLayer

  alias Gits.Storefront.Order

  postgres do
    table "tickets"
    repo Gits.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :order, Order
  end
end
