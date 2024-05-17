defmodule Gits.Dashboard.Venue do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshArchival.Resource],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id
    attribute :place_id, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :google_maps_uri, :string, allow_nil?: false, public?: true
    attribute :formatted_address, :string, allow_nil?: false, public?: true
    attribute :type, :string, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account

    has_many :events, Gits.Storefront.Event do
      domain Gits.Storefront
    end
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    create :create do
      accept [:*]

      upsert? true
      upsert_identity :google_place_id

      argument :event, :map

      change manage_relationship(:event, :events, type: :append)
    end
  end

  postgres do
    table "venues"
    repo Gits.Repo
  end

  identities do
    identity :google_place_id, :place_id
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end
end

defmodule Gits.Dashboard.Venue.DetailedGoogleAddress do
  use Ash.Resource,
    domain: Gits.Dashboard

  attributes do
    attribute :id, :string, primary_key?: true, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :google_maps_uri, :string, allow_nil?: false, public?: true
    attribute :formatted_address, :string, allow_nil?: false, public?: true
    attribute :type, :string, public?: true
  end

  actions do
    read :fetch_from_api do
      argument :id, :string, allow_nil?: false

      manual Gits.Dashboard.Actions.ReadGoogleAddress
    end
  end
end

defmodule Gits.Dashboard.Venue.GoogleAddress do
  use Ash.Resource,
    domain: Gits.Dashboard

  attributes do
    attribute :id, :string, allow_nil?: false, primary_key?: true, public?: true
    attribute :main_text, :string, allow_nil?: false, public?: true
    attribute :secondary_text, :string, allow_nil?: false, public?: true
  end

  actions do
    read :search do
      primary? true

      argument :query, :string

      manual Gits.Dashboard.Actions.ReadGoogleAddressSuggestions
    end
  end
end
