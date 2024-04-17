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
      attribute_public? true
      attribute_writable? true
      domain Gits.Auth
    end

    has_many :instances, Gits.Storefront.TicketInstance
  end

  identities do
    identity :unique_user_id, :user_id
  end

  actions do
    default_accept :*
    defaults [:read]

    create :create do
      accept :*

      upsert? true
      upsert_identity :unique_user_id
    end
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "customers"
    repo Gits.Repo
  end
end
