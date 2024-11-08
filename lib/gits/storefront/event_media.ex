defmodule Gits.Storefront.EventMedia do
  alias Gits.Storefront.Event

  use Ash.Resource,
    domain: Gits.Storefront,
    extensions: [AshArchival.Resource]

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :feature_graphic_url, :string, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, Event
  end
end
