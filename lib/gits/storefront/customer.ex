defmodule Gits.Storefront.Customer do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :user, Gits.Auth.User do
      domain Gits.Auth
    end

    has_many :instances, Gits.Storefront.TicketInstance
  end

  calculations do
    calculate :name, :string, expr(user.display_name)
  end

  identities do
    identity :unique_user_id, :user_id
  end

  actions do
    defaults [:read]

    create :create do
      argument :user, :map, allow_nil?: false

      change manage_relationship(:user, type: :append)

      upsert? true
      upsert_identity :unique_user_id
    end

    update :add_ticket do
      require_atomic? false
      argument :ticket, :map
    end
  end

  policies do
    policy action(:read) do
      authorize_if actor_present()
    end

    policy action(:create) do
      authorize_if always()
    end
  end

  postgres do
    table "customers"
    repo Gits.Repo
  end
end
