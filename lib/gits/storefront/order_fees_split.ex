defmodule Gits.Storefront.OrderFeesSplit do
  alias Gits.Repo
  alias Gits.Storefront.Order

  use Ash.Resource,
    domain: Gits.Storefront,
    authorizers: Ash.Policy.Authorizer,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    table "order_fees_splits"
    repo Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  policies do
    policy action(:create) do
      authorize_if accessing_from(Order, :fees_split)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :integration, :decimal, public?: true
    attribute :paystack, :decimal, public?: true
    attribute :subaccount, :decimal, public?: true
  end

  relationships do
    belongs_to :order, Order
  end
end
