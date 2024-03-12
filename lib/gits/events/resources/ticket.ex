defmodule Gits.Events.Ticket do
  use Ash.Resource, data_layer: AshPostgres.DataLayer, extensions: [AshArchival.Resource]

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    attribute :price, :integer, allow_nil?: false

    create_timestamp :created_at, private?: false

    update_timestamp :updated_at, private?: false
  end

  aggregates do
    count :user_tickets, [:ticket_instances], filterable?: true
  end

  relationships do
    belongs_to :event, Gits.Events.Event, attribute_writable?: true
    has_many :ticket_instances, Gits.Events.TicketInstance
  end

  actions do
    defaults [:read, :create, :update]

    update :add_instance do
      argument :instance, :map do
        allow_nil? false
      end

      change manage_relationship(:instance, :ticket_instances, type: :create)
    end

    update :remove_instance do
      argument :instance, :map do
        allow_nil? false
      end

      change manage_relationship(:instance, :ticket_instances, type: :remove)
    end
  end

  postgres do
    table "tickets"
    repo Gits.Repo
  end
end
