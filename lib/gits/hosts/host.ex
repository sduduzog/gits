defmodule Gits.Hosts.Host do
  alias Gits.Hosts.Role
  alias Gits.Auth
  alias Gits.Auth.User

  use Ash.Resource,
    domain: Gits.Hosts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    repo Gits.Repo
    table "hosts"
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true, allow_nil?: false

    attribute :handle, :string,
      public?: true,
      allow_nil?: false,
      constraints: [match: ~r"^[a-z0-9](-?[a-z0-9])*$", min_length: 3]

    attribute :logo, :string, public?: true

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
