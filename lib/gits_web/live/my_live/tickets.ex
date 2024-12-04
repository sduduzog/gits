defmodule GitsWeb.MyLive.Tickets do
  require Ash.Query
  alias Gits.Storefront.Ticket
  alias Gits.Storefront.TicketType
  alias Gits.Storefront.Event
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    assign(socket, :page_title, "Tickets")
    |> ok()
  end

  def handle_params(%{"order" => order}, _uri, socket) do
    Ash.Query.filter(Event, orders.id == ^order)
    |> Ash.Query.load(:host)
    |> Ash.Query.sort(starts_at: :desc)
    |> Ash.Query.load(
      ticket_types:
        Ash.Query.load(TicketType, tickets: Ash.Query.filter(Ticket, order.id == ^order))
    )
    |> Ash.read()
    |> case do
      {:ok, events} -> assign(socket, :events, prepare_events(events))
    end
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    user = socket.assigns.current_user

    if user do
      Ash.Query.filter(Event, orders.email == ^user.email)
      |> Ash.Query.load(:host)
      |> Ash.Query.sort(starts_at: :asc)
      |> Ash.Query.load(
        ticket_types:
          Ash.Query.load(TicketType,
            tickets: Ash.Query.filter(Ticket, order.email == ^user.email)
          )
      )
      |> Ash.read()
      |> case do
        {:ok, events} -> assign(socket, :events, prepare_events(events))
      end
      |> noreply()
    else
      assign(socket, :events, [])
      |> noreply()
    end
  end

  def prepare_events(events) do
    Enum.map(events, fn event ->
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

      {event.name, event.starts_at, ticket_types, event.host.name}
    end)
  end
end
