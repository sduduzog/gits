defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Events.TicketInstance
  alias Gits.Events.Event

  def home(conn, _params) do
    events =
      Event
      |> Gits.Events.read!()

    conn
    |> assign(:events, events)
    |> render(:home)
  end

  def event(conn, params) do
    event =
      Event
      |> Ash.Query.filter(id: params["id"])
      |> Gits.Events.read_one!()

    conn
    |> assign(:event, event)
    |> render(:event)
  end

  def settings(conn, _params) do
    conn
    |> render(:settings)
  end

  def tickets(conn, _params) do
    ticket_instances =
      TicketInstance
      |> Ash.Query.filter(user_id: conn.assigns.current_user.id)
      |> Ash.Query.sort(ticket_id: :asc)
      |> Gits.Events.read!()
      |> Gits.Events.load!(ticket: [:event])
      |> IO.inspect()

    events =
      Event
      |> Gits.Events.read!()

    conn
    |> assign(:ticket_instances, ticket_instances)
    |> assign(:events, events)
    |> render(:tickets)
  end

  def search(conn, _params) do
    render(conn, :search)
  end
end
