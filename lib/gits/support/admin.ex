defmodule Gits.Support.Admin do
  alias Gits.Accounts
  alias Gits.Accounts.User
  alias Gits.Support

  use Ash.Resource,
    domain: Support,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer

  postgres do
    table "support_admins"
    repo Gits.Repo
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      argument :user, :map, allow_nil?: false

      change manage_relationship(:user, type: :append)
    end
  end

  policies do
    policy action(:read) do
      authorize_if accessing_from(User, :admin)
    end

    policy action(:create) do
      authorize_if actor_present()
    end
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :user, User, domain: Accounts
  end
end
