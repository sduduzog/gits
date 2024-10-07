defmodule Gits.Hosts.Host do
  use Ash.Resource, extensions: [AshArchival.Resource]

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :slug, :string, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :owner, Gits.Auth.User do
      domain Gits.Auth
    end
  end
end
