defmodule Gits.Storefront.Ticket do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event
  end

  actions do
    defaults [:create, :read, :update]
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "tickets"
    repo Gits.Repo
  end
end
