defmodule Gits.Events.TicketInstance do
  use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshArchival.Resource], domain: Gits.Events

  attributes do
    integer_primary_key :id

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :ticket, Gits.Events.Ticket, attribute_writable?: true

    belongs_to :user, Gits.Accounts.User,
      attribute_writable?: true,
      domain: Gits.Accounts
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  postgres do
    table "ticket_instances"
    repo Gits.Repo
  end
end
