defmodule Gits.Hosts.EventDetails do
  alias Gits.Hosts.Event

  use Ash.Resource,
    domain: Gits.Hosts,
    extensions: [AshArchival.Resource]

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :description, :string, allow_nil?: false
    attribute :visibility, :atom, constraints: [one_of: [:private, :public]]

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, Event
  end
end
