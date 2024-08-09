defmodule Gits.Storefront.Customer do
  alias Gits.Storefront.{Ticket, TicketInstance}

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :user, Gits.Auth.User do
      domain Gits.Auth
    end

    has_many :instances, Gits.Storefront.TicketInstance

    has_many :scannable_instances, Gits.Storefront.TicketInstance do
      filter expr(state in [:ready_for_use])
    end
  end

  calculations do
    calculate :tickets_total_price, :integer do
      calculation expr(
                    sum(tickets,
                      field: :price,
                      query: [filter: expr(event.id == ^arg(:event_id))]
                    )
                  )

      argument :event_id, :integer do
        allow_nil? false
      end
    end

    calculate :tickets_count, :integer do
      calculation expr(
                    count(tickets,
                      query: [
                        filter: expr(event.id == ^arg(:event_id) and instances.state == :reserved)
                      ]
                    )
                  )

      argument :event_id, :integer do
        allow_nil? false
      end
    end
  end

  identities do
    identity :unique_user_id, :user_id
  end

  actions do
    defaults [:read]

    create :create do
      argument :user, :map, allow_nil?: false

      change manage_relationship(:user, type: :append)

      upsert? true
      upsert_identity :unique_user_id
    end

    update :add_ticket do
      require_atomic? false
      argument :ticket, :map
    end
  end

  policies do
    bypass action(:read) do
      authorize_if Gits.Checks.ActorIsObanJob
    end

    policy action(:read) do
      authorize_if accessing_from(TicketInstance, :customer)
      authorize_if expr(user.id == ^actor(:id))
    end

    policy action(:create) do
      authorize_if always()
    end
  end

  postgres do
    table "customers"
    repo Gits.Repo
  end
end
