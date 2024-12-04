defmodule Gits.Accounts.Role do
  alias Gits.Accounts.{Host, RoleType, User}

  use Ash.Resource,
    domain: Gits.Accounts,
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
    belongs_to :user, User

    belongs_to :host, Host
  end
end
