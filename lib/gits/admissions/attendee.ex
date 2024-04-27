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
      domain Gits.Storefront
    end

    belongs_to :instance, Gits.Storefront.TicketInstance do
      domain Gits.Storefront
    end
  end

  identities do
    identity :admission_identity, [:user_id, :event_id, :instance_id]
  end

  postgres do
    table "attendees"
    repo Gits.Repo
  end
end
