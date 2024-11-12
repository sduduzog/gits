defmodule Gits.Storefront.Ticket do
  use Ash.Resource, domain: Gits.Storefront, data_layer: AshPostgres.DataLayer

  alias Gits.Storefront.{Order, TicketType}

  postgres do
    table "tickets"
    repo Gits.Repo
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :order, Order, allow_nil?: false
    belongs_to :ticket_type, TicketType, allow_nil?: false
  end
end
