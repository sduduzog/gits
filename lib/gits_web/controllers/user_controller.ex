defmodule GitsWeb.UserController do
  use GitsWeb, :controller
  require Ash.Query

  alias Gits.Storefront.Event
  alias Gits.Storefront.TicketInstance

  def events(conn, _) do
    conn
    |> render(:events)
  end

  def ticket(conn, params) do
    user = conn.assigns.current_user

    conn =
      Event
      |> Ash.Query.for_read(:read, %{masked_id: params["id"]}, actor: user)
      |> Ash.read_one()
      |> case do
        {:error, _} -> raise GitsWeb.Exceptions.NotFound, "no tickets"
        {:ok, event} -> conn |> assign(:event, event)
      end

    conn
    |> put_layout(false)
    |> render(:ticket)
  end

  def tickets(conn, _) do
    user =
      conn.assigns.current_user

    conn =
      TicketInstance
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(state == :ready_for_use)
      |> Ash.Query.load([:event_id, :event_name, :ticket_name, :event_starts_at])
      |> Ash.Query.sort(id: :asc)
      |> Ash.read()
      |> case do
        {:error, _} -> raise GitsWeb.Exceptions.NotFound, "no tickets"
        {:ok, instances} -> conn |> assign(:instances, instances)
      end

    conn
    |> put_layout(false)
    |> render(:tickets)
  end

  def profile(conn, _) do
    conn
    |> render(:profile)
  end

  def settings(conn, _) do
    conn
    |> render(:settings)
  end
end
