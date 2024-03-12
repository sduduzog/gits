defmodule Gits.Events.TicketInstance do
  use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshArchival.Resource]

  attributes do
    integer_primary_key :id

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  relationships do
    belongs_to :ticket, Gits.Events.Ticket, attribute_writable?: true

    belongs_to :user, Gits.Accounts.User,
      attribute_writable?: true,
      api: Gits.Accounts
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  postgres do
    table "ticket_instances"
    repo Gits.Repo
  end
end
