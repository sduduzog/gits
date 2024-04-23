defmodule Gits.Storefront.Customer do
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
      attribute_public? true
      attribute_writable? true
      domain Gits.Auth
    end

    has_many :instances, Gits.Storefront.TicketInstance

    has_many :scannable_instances, Gits.Storefront.TicketInstance do
      filter expr(state in [:ready_to_scan])
    end

    many_to_many :tickets, Gits.Storefront.Ticket do
      through Gits.Storefront.TicketInstance
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

    calculate :ready_tickets_count, :integer do
      calculation expr(
                    count(tickets,
                      query: [
                        filter:
                          expr(event.id == ^arg(:event_id) and instances.state == :ready_to_scan)
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
    default_accept :*
    defaults [:read]

    create :create do
      accept :*

      upsert? true
      upsert_identity :unique_user_id
    end

    update :add_ticket do
      require_atomic? false
      argument :ticket, :map
    end
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "customers"
    repo Gits.Repo
  end
end
