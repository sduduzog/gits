defmodule Gits.Dashboard.Venue do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshArchival.Resource],
    domain: Gits.Dashboard

  attributes do
    attribute :id, :string, primary_key?: true, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :address, :string, allow_nil?: false, public?: true
    attribute :latitude, :float, allow_nil?: false, public?: true
    attribute :longitude, :float, allow_nil?: false, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*, create: :*]
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end
  end

  postgres do
    table "venues"
    repo Gits.Repo
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

      manual Gits.Dashboard.Actions.ReadGoogleAddress
    end
  end
end
