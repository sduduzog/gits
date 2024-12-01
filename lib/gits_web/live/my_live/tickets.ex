defmodule GitsWeb.MyLive.Tickets do
  require Ash.Query
  alias Gits.Storefront.TicketType
  alias Gits.Storefront.Event
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    Ash.Query.filter(Event, count(ticket_types.tickets) > 0)
    |> Ash.Query.sort(starts_at: :desc)
    |> Ash.Query.load(
      ticket_types: Ash.Query.filter(TicketType, count(tickets) > 0) |> Ash.Query.load(:tickets)
    )
    |> Ash.read()
    |> case do
      {:ok, events} ->
        events =
          events
          |> Enum.map(fn event ->
            event |> IO.inspect()

            ticket_types =
              event.ticket_types
              |> Enum.map(fn type ->
                tickets =
                  type.tickets
                  |> Enum.map(fn ticket ->
                    {ticket.public_id}
                  end)

                {type.name, tickets}
              end)

            {event.name, event.starts_at, ticket_types}
          end)

        socket
        |> assign(:events, events)

      _ ->
        socket
        |> assign(:tickets, [])
    end
    |> assign(:tickets, [])
    |> assign(:page_title, "Tickets")
    |> ok()
  end
end
