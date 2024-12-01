defmodule Gits.Storefront.Ticket do
  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  alias Gits.Storefront.{Order, TicketType}

  postgres do
    table "tickets"
    repo Gits.Repo
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true

      argument :ticket_type, :map, allow_nil?: false

      change manage_relationship(:ticket_type, type: :append)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :public_id, :string,
      allow_nil?: false,
      writable?: false,
      public?: true,
      default: fn -> Nanoid.generate(6, "0123456789abcdef") end
  end

  relationships do
    belongs_to :order, Order, allow_nil?: false
    belongs_to :ticket_type, TicketType, allow_nil?: false
  end

  calculations do
    calculate :ticket_type_name, :string, expr(ticket_type.name)
  end
end
