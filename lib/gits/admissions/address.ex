defmodule Gits.Admissions.Address do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    domain: Gits.Admissions

  attributes do
    uuid_primary_key :id

    attribute :place_id, :string, allow_nil?: false

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    has_many :events, Gits.Storefront.Event do
      domain Gits.Storefront
    end
  end

  identities do
    identity :unique_place, [:place_id]
  end

  actions do
    defaults [:read, :destroy, update: :*, create: :*]
  end

  postgres do
    table "addresses"
    repo Gits.Repo
  end
end
