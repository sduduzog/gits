defmodule Gits.Events.Event do
  use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshArchival.Resource]

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  relationships do
    belongs_to :account, Gits.Accounts.Account do
      api Gits.Accounts
    end

    has_many :tickets, Gits.Events.Ticket
  end

  actions do
    defaults [:read, :create]
  end

  postgres do
    table "events"
    repo Gits.Repo
  end
end
