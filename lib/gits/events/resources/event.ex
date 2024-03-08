defmodule Gits.Events.Event do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
  end

  actions do
    defaults [:read, :create]
  end

  postgres do
    table "events"
    repo Gits.Repo
  end
end
