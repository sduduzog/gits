defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Events.TicketInstance
  alias Gits.Events.Event

  def home(conn, _params) do
    events =
      Event
      |> Ash.read!()

    conn
    |> assign(:events, events)
    |> render(:home)
  end

  def organizers(conn, _) do
    render(conn, :organizers)
  end

  def event(conn, params) do
    event =
      Event
      |> Ash.Query.filter(id: params["id"])
      |> Ash.read_one!()

    conn
    |> assign(:event, event)
    |> render(:event)
  end

  def settings(conn, _params) do
    conn
    |> render(:settings)
  end

  def tickets(conn, _params) do
    events =
      Event
      |> Ash.Query.filter(starts_at > now())

    ticket_instances =
      TicketInstance
      |> Ash.Query.filter(user_id: conn.assigns.current_user.id)
      |> Ash.Query.sort(ticket_id: :asc)
      |> Ash.read!()
      |> Ash.load!(ticket: [event: events])
      |> Enum.filter(fn x -> x.ticket.event end)
      |> Enum.sort_by(& &1.ticket.event.starts_at)

    conn
    |> assign(:ticket_instances, ticket_instances)
    |> assign(:events, events)
    |> render(:tickets)
  end

  def search(conn, _params) do
    render(conn, :search)
  end
end
