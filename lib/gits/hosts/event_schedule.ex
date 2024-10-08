defmodule Gits.Hosts.EventSchedule do
  alias Gits.Hosts.{Event, Venue}

  use Ash.Resource,
    domain: Gits.Hosts,
    extensions: [AshArchival.Resource]

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id

    attribute :starts_at, :string, allow_nil?: false
    attribute :ends_at, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, Event

    belongs_to :venue, Venue
  end
end
