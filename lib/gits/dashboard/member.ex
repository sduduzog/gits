defmodule Gits.Dashboard.Member do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id

    attribute :role, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:owner, :admin, :access_coordinator]
      default :owner
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account

    belongs_to :user, Gits.Auth.User do
      domain Gits.Auth
    end
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      accept :*

      argument :user, :map

      change manage_relationship(:user, type: :append)
    end
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if Gits.Checks.CanCreate
    end
  end

  postgres do
    table "members"
    repo Gits.Repo
  end
end
