defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  alias Gits.Events.Event

  def home(conn, _params) do
    events =
      Event
      |> Gits.Events.read!()

    conn
    |> assign(:events, events)
    |> render(:home)
  end

  def event(conn, _) do
    event =
      Event
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
    render(conn, :tickets)
  end

  def search(conn, _params) do
    render(conn, :search)
  end
end
