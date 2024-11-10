defmodule Gits.Storefront.Interaction do
  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "interactions"
    repo Gits.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :type, :atom,
      public?: true,
      constraints: [one_of: [:view_event]]

    create_timestamp :created_at
  end
end
