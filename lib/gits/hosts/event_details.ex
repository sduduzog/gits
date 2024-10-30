defmodule Gits.Hosts.EventDetails do
  require Ash.Resource.Change.Builtins
  alias Gits.Hosts.Event

  use Ash.Resource,
    domain: Gits.Hosts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    table "event_details"
    repo Gits.Repo
  end

  actions do
    defaults [:read, :destroy, update: :*, create: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true, allow_nil?: false
    attribute :description, :string, public?: true, allow_nil?: false
    attribute :visibility, :atom, public?: true, constraints: [one_of: [:private, :public]]

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, Event
  end
end
