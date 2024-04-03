defmodule Gits.Events.Ticket do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Events

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    attribute :price, :integer, allow_nil?: false

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  aggregates do
    count :user_tickets, [:ticket_instances], filterable?: true
  end

  relationships do
    belongs_to :event, Gits.Events.Event
    has_many :ticket_instances, Gits.Events.TicketInstance
  end

  actions do
    defaults [:read, :update]

    create :create do
      argument :event, :map do
        allow_nil? false
      end

      change manage_relationship(:event, type: :append)
    end

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

  policies do
    policy action(:create) do
      authorize_if Gits.Checks.CanCreateTicket
    end

    policy action(:update) do
      authorize_if Gits.Checks.CanEditEventDetails
    end
  end

  postgres do
    table "tickets"
    repo Gits.Repo
  end
end
