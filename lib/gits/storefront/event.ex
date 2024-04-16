defmodule Gits.Storefront.Event do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, allow_nil?: false, public?: true
    attribute :starts_at, :naive_datetime, allow_nil?: false, public?: true
    attribute :address_place_id, :string, allow_nil?: true
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account do
      domain Gits.Dashboard
    end
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    create :first_event do
      primary? true
      accept :*
    end

    create :create do
      accept :*

      argument :account, :map

      change manage_relationship(:account, type: :append)
    end

    update :update_address do
      accept :address_place_id
    end
  end

  postgres do
    table "events"
    repo Gits.Repo
  end
end
