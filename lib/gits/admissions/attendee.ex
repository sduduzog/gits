defmodule Gits.Admissions.Attendee do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Admissions

  attributes do
    uuid_primary_key :id

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :user, Gits.Auth.User do
      domain Gits.Auth
    end

    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
      domain Gits.Storefront
    end

    belongs_to :instance, Gits.Storefront.TicketInstance do
      attribute_type :integer
      domain Gits.Storefront
    end
  end

  identities do
    identity :admission_identity, [:user_id, :event_id, :instance_id]
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :admit do
      argument :user, :map do
        allow_nil? false
      end

      argument :event, :map do
        allow_nil? false
      end

      argument :instance, :map do
        allow_nil? false
      end

      change manage_relationship(:user, type: :append)
      change manage_relationship(:event, type: :append)
      change manage_relationship(:instance, type: :append)
    end
  end

  policies do
    policy always() do
      authorize_if actor_present()
    end
  end

  postgres do
    table "attendees"
    repo Gits.Repo
  end
end
