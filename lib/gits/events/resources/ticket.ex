defmodule Gits.Events.Ticket do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    attribute :price, :integer, allow_nil?: false

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  relationships do
    belongs_to :event, Gits.Events.Event, attribute_writable?: true
  end

  actions do
    defaults [:read, :create, :update]
  end

  postgres do
    table "tickets"
    repo Gits.Repo
  end
end
