defmodule Gits.Storefront.Interaction do
  use Ash.Resource,
    domain: Gits.Storefront,
    authorizers: Ash.Policy.Authorizer,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "interactions"
    repo Gits.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :type, :atom,
      public?: true,
      constraints: [one_of: [:view]]

    create_timestamp :created_at
  end
end
