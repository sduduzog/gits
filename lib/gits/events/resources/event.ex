defmodule Gits.Events.Event do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Events

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    attribute :description, :string, allow_nil?: false
    attribute :starts_at, :naive_datetime, allow_nil?: false
  end

  actions do
    defaults [:read, :update]
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "events"
    repo Gits.Repo
  end
end
