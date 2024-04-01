defmodule Gits.Events.Attendee do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    attribute :email, :ci_string, allow_nil?: false

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  relationships do
    belongs_to :instance, Gits.Events.TicketInstance do
      api Gits.Events
      attribute_type Ash.Type.Integer
      attribute_writable? true
    end

    belongs_to :event, Gits.Events.Event do
      api Gits.Events
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
