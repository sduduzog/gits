defmodule Gits.Accounts.Venue do
  alias Gits.Accounts
  alias Gits.Accounts.{Host, User}
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

      accept :*

      argument :host, :map, allow_nil?: false

      change manage_relationship(:host, type: :append)
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
