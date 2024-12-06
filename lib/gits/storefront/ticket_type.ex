defmodule Gits.Storefront.TicketType do
  alias Gits.Storefront.{Event, Ticket}

  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    table "ticket_types"
    repo Gits.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true, allow_nil?: false
    attribute :price, :decimal, public?: true, allow_nil?: false, default: 0
    attribute :description, :string, public?: true

    attribute :sale_starts_at, :naive_datetime, public?: true, allow_nil?: false
    attribute :sale_ends_at, :naive_datetime, public?: true, allow_nil?: false

    attribute :quantity, :integer, public?: true, allow_nil?: false, default: 10
    attribute :limit_per_user, :integer, public?: true, allow_nil?: false, default: 10

    attribute :color, :string,
      public?: true,
      default: fn -> "#" <> Nanoid.generate(6, "0123456789abcdef") end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, Event

    has_many :tickets, Ticket
  end
end
