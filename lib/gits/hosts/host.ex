defmodule Gits.Hosts.Host do
  alias Gits.Hosts.Role
  alias Gits.Auth
  alias Gits.Auth.User

  use Ash.Resource,
    domain: Gits.Hosts,
    extensions: [AshArchival.Resource]

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :slug, :string, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :owner, User do
      domain Auth
    end

    has_many :roles, Role
  end
end
