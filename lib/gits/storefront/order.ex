defmodule Gits.Storefront.Order do
  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "orders"
    repo Gits.Repo
  end

  actions do
    defaults [:read, create: []]
  end

  attributes do
    uuid_primary_key :id
  end
end
