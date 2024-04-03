defmodule Gits.Events.Event do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Events

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    attribute :starts_at, :naive_datetime, allow_nil?: false

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :account, Gits.Accounts.Account do
      domain Gits.Accounts
    end

    has_many :tickets, Gits.Events.Ticket
  end

  actions do
    defaults [:read, :update]

    create :create do
      argument :account, :map, allow_nil?: false
      change manage_relationship(:account, type: :append)
    end
  end

  policies do
    policy always() do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if Gits.Checks.CanCreateEvent
    end

    policy action(:update) do
      authorize_if Gits.Checks.CanEditEventDetails
    end
  end

  postgres do
    table "events"
    repo(Gits.Repo)
  end
end
