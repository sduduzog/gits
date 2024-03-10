defmodule Gits.Events.Cart do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    integer_primary_key :id

    attribute :name, :string, allow_nil?: false

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  relationships do
    belongs_to :event, Gits.Events.Event
    has_one :payment, Gits.Events.CartPayment
  end

  actions do
    defaults [:read, :create]
  end

  postgres do
    table "carts"
    repo Gits.Repo
  end
end
