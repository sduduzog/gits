defmodule Gits.Storefront.Interaction do
  alias Gits.Accounts
  alias Gits.Accounts.User
  alias Gits.Storefront.Event

  use Ash.Resource,
    domain: Gits.Storefront,
    authorizers: Ash.Policy.Authorizer,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "interactions"
    repo Gits.Repo
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true

      accept [:type, :viewer_id]

      argument :event, :map
      argument :user, :map

      change manage_relationship(:event, type: :append)
      change manage_relationship(:user, type: :append)
    end
  end

  policies do
    policy action([:read, :create]) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :viewer_id, :string, public?: true

    attribute :type, :atom,
      public?: true,
      constraints: [one_of: [:view]]

    create_timestamp :created_at
  end

  relationships do
    belongs_to :user, User, domain: Accounts
    belongs_to :event, Event
  end
end
