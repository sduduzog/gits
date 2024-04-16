defmodule Gits.Storefront.TicketInstance do
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
    belongs_to :ticket, Gits.Storefront.Ticket
  end

  actions do
    default_accept :*
    defaults [:read, :update, :destroy]

    create :create do
      accept :*

      argument :ticket, :map

      change manage_relationship(:ticket, type: :append)
    end
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "ticket_instances"
    repo Gits.Repo
  end
end
