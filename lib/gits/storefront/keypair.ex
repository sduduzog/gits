defmodule Gits.Storefront.Keypair do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Gits.Storefront

  attributes do
    attribute :private_key, :string, allow_nil?: false, public?: true

    attribute :public_key, :string, allow_nil?: false, public?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      allow_nil? false
      attribute_type :integer
      primary_key? true
    end
  end

  calculations do
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  postgres do
    table "keypairs"
    repo Gits.Repo
  end
end
