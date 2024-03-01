defmodule Gits.Accounts.Profile do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  actions do
    defaults [:create, :read, :update]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
  end

  relationships do
    belongs_to :user, Gits.Accounts.User
  end

  postgres do
    table "profiles"
    repo Gits.Repo
  end

  graphql do
    type :profile
  end
end
