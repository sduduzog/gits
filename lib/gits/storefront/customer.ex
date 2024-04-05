defmodule Gits.Storefront.Customer do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id
  end

  postgres do
    table "customers"
    repo Gits.Repo
  end
end
