defmodule Gits.Events.CartPayment do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  relationships do
    belongs_to :cart, Gits.Events.Cart do
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :create]
  end

  postgres do
    table "cart_payments"
    repo Gits.Repo
  end
end
