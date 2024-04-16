defmodule Gits.Storefront.Customer do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  postgres do
    table "customers"
    repo Gits.Repo
  end
end
