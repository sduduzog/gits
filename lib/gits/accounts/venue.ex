defmodule Gits.Accounts.Venue do
  alias Gits.Accounts
  alias Gits.Accounts.User

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
    belongs_to_actor :user, User
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, public?: true, allow_nil?: false
    attribute :google_place_id, :string, public?: true, allow_nil?: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end
end
