defmodule Gits.Events.Attendee do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    domain: Gits.Events

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    attribute :email, :ci_string, allow_nil?: false

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :instance, Gits.Events.TicketInstance do
      attribute_type Ash.Type.Integer
      attribute_writable? true
    end

    belongs_to :event, Gits.Events.Event do
      attribute_writable? true
    end
  end

  actions do
    defaults [:create, :read]
  end

  identities do
    identity :unique_per_event, [:email, :event_id] do
      eager_check_with Gits.Events
      message "already used"
    end
  end

  postgres do
    table "attendees"
    repo Gits.Repo
  end
end
