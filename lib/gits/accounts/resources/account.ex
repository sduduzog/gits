defmodule Gits.Accounts.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :type, :atom do
      constraints one_of: [:user]

      default :user

      allow_nil? false
    end

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  relationships do
    has_many :events, Gits.Events.Event do
      api Gits.Events
    end
  end

  actions do
    defaults [:create, :read]
  end

  postgres do
    table "accounts"
    repo Gits.Repo
  end

  relationships do
    has_many :roles, Gits.Accounts.Role
  end
end
