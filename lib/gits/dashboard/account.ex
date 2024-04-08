defmodule Gits.Dashboard.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, Gits.Dashboard.Member
    has_many :events, Gits.Dashboard.Event
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    create :create do
      accept :*

      argument :member, :map
      argument :event, :map
      change manage_relationship(:member, :members, type: :create)
      change manage_relationship(:event, :events, type: :create)
    end
  end

  postgres do
    table "accounts"
    repo Gits.Repo
  end
end
