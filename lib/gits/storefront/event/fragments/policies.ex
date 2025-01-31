defmodule Gits.Storefront.Event.Fragments.Policies do
  require Decimal
  alias Gits.Accounts.{Venue}
  alias Gits.Storefront.{EventCategory, Interaction, Order, Ticket, TicketType}

  alias Gits.Storefront.Event.Checks.ActorCanCreateEvent
  alias Gits.Storefront.Event.Notifiers.{EventUpdated}

  use Spark.Dsl.Fragment,
    of: Ash.Resource,
    authorizers: Ash.Policy.Authorizer

  policies do
    policy action(:read) do
      authorize_if expr(not is_nil(published_at))
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:archived) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:create) do
      authorize_if ActorCanCreateEvent
    end

    policy action(:details) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy changing_attributes(visibility: [from: :private, to: :public]) do
      authorize_if expr(host.state == :verified)
    end

    policy action(:create_venue) do
      authorize_if actor_present()
    end

    policy action(:use_venue) do
      authorize_if actor_present()
    end

    policy action(:remove_venue) do
      authorize_if actor_present()
    end

    policy action(:location) do
      authorize_if actor_present()
    end

    policy action(:description) do
      authorize_if actor_present()
    end

    policy action(:media) do
      authorize_if actor_present()
    end

    policy action(:add_ticket_type) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:edit_ticket_type) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:archive_ticket_type) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:sort_ticket_types) do
      authorize_if expr(host.roles.user.id == ^actor(:id))
    end

    policy action(:publish) do
      authorize_if expr(exists(host.roles, user.id == ^actor(:id)))
    end

    policy action(:publish) do
      authorize_if expr(not start_date_invalid?)
    end

    policy action(:publish) do
      authorize_if expr(not end_date_invalid?)
    end

    policy action(:publish) do
      authorize_if expr(not poster_invalid?)
    end

    policy action(:publish) do
      authorize_if expr(not venue_invalid?)
    end

    policy action(:publish) do
      authorize_if AshStateMachine.Checks.ValidNextState
    end

    policy action(:create_order) do
      authorize_if expr(has_tickets?)
    end

    policy action(:destroy) do
      authorize_if always()
    end

    policy action(:complete) do
      authorize_if actor_attribute_equals(
                     :worker,
                     to_string(EventUpdated) |> String.replace("Elixir.", "")
                   )
    end
  end
end
