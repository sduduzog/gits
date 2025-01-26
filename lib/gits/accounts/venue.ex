defmodule Gits.Accounts.Venue do
  alias Gits.GooglePlaces
  alias Gits.Accounts
  alias Gits.Accounts.{Host}
  alias Gits.Storefront
  alias Gits.Storefront.Event

  use Ash.Resource,
    domain: Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshPaperTrail.Resource]

  postgres do
    table "venues"
    repo Gits.Repo
  end

  paper_trail do
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      upsert? true

      accept [:google_place_id]

      argument :host, :map, allow_nil?: false

      change manage_relationship(:host, type: :append)

      upsert_identity :place_id

      change fn changeset, _ ->
        google_place_id = Ash.Changeset.get_attribute(changeset, :google_place_id)
        {:ok, details} = GooglePlaces.get_place_details(google_place_id, :cache)

        %{
          name: "Mea Culpa",
          address: "35 11th Rd, Kew, Johannesburg",
          place_uri: "https://maps.google.com/?cid=6362034033745938108",
          surburb: "Kew",
          city_or_town: "Johannesburg",
          province: "Gauteng",
          postal_code: "2090",
          latitude: -26.121423699999998,
          longitude: 28.087158199999998
        }

        Map.to_list(details)
        |> Enum.reduce(changeset, fn {key, value}, acc ->
          Ash.Changeset.change_new_attribute(acc, key, value)
        end)
      end
    end
  end

  policies do
    policy action([:read, :create, :update]) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, public?: true, allow_nil?: false
    attribute :address, :string, public?: true, allow_nil?: false
    attribute :google_place_id, :string, public?: true, allow_nil?: false
    attribute :place_uri, :string, public?: true
    attribute :surburb, :string, public?: true
    attribute :city_or_town, :string, public?: true
    attribute :province, :string, public?: true, allow_nil?: false
    attribute :postal_code, :string, public?: true
    attribute :latitude, :decimal, public?: true, allow_nil?: false
    attribute :longitude, :decimal, public?: true, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :host, Host, allow_nil?: false
    has_many :events, Event, domain: Storefront
  end

  identities do
    identity :place_id, [:google_place_id]
  end
end
