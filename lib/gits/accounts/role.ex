defmodule Gits.Accounts.Role do
  alias Gits.Accounts.{Host, RoleType, User}

  use Ash.Resource,
    domain: Gits.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource]

  postgres do
    repo Gits.Repo
    table "host_roles"
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true

      accept [:type]

      argument :user, :map, allow_nil?: false
      change manage_relationship(:user, type: :append)
    end
  end

  policies do
    policy action(:read) do
      authorize_if expr(user.id == ^actor(:id))
      authorize_if accessing_from(Host, :roles)
      authorize_if accessing_from(User, :roles)
    end

    policy action(:create) do
      authorize_if accessing_from(Host, :roles)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :type, RoleType

    create_timestamp :created_at
  end

  relationships do
    belongs_to :user, User, public?: true, allow_nil?: false

    belongs_to :host, Host, public?: true, allow_nil?: false
  end
end
