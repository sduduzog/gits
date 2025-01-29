defmodule Gits.Storefront.TicketType.Fragments.Policies do
  alias Gits.Storefront.{Event, Order, Ticket}

  use Spark.Dsl.Fragment,
    of: Ash.Resource,
    authorizers: Ash.Policy.Authorizer

  policies do
    policy action(:read) do
      authorize_if accessing_from(Event, :ticket_types)
      authorize_if accessing_from(Order, :ticket_types)
      authorize_if accessing_from(Ticket, :ticket_type)
    end

    policy action(:create) do
      authorize_if actor_present()
      authorize_if accessing_from(Event, :ticket_types)
    end

    policy action([:update, :order]) do
      authorize_if actor_present()
      authorize_if accessing_from(Order, :ticket_types)
      authorize_if accessing_from(Event, :ticket_types)
    end

    policy action(:destroy) do
      authorize_if actor_present()
      authorize_if accessing_from(Event, :ticket_types)
    end

    policy action(:add_ticket) do
      authorize_if accessing_from(Order, :ticket_types)
    end

    policy action(:add_ticket) do
      authorize_if expr(on_sale?)
    end

    policy action(:add_ticket) do
      authorize_if expr(valid_tickets_count < quantity)
    end

    policy action(:remove_ticket) do
      authorize_if accessing_from(Order, :ticket_types)
    end
  end
end
