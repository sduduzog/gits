defmodule Gits.Hosts.Role do
  alias Gits.Hosts.{Host, RoleType}

  alias Gits.Auth
  alias Gits.Auth.User

  use Ash.Resource,
    domain: Gits.Hosts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    repo Gits.Repo
    table "host_roles"
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :slug, :string, allow_nil?: false

    attribute :type, RoleType

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, User do
      domain Auth
    end

    belongs_to :host, Host
  end
end
