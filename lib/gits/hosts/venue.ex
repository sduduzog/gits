defmodule Gits.Hosts.Venue do
  alias Gits.Hosts.Host

  use Ash.Resource,
    domain: Gits.Hosts,
    extensions: [AshArchival.Resource]

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :host, Host
  end
end
