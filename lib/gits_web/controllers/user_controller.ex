defmodule GitsWeb.UserController do
  use GitsWeb, :controller

  alias Gits.Storefront.Ticket
  alias Gits.Storefront.TicketInstance

  def events(conn, _) do
    conn
    |> render(:events)
  end

  def ticket(conn, _) do
    conn
    |> put_layout(false)
    |> render(:ticket)
  end

  def tickets(conn, _) do
    user = conn.assigns.current_user

    conn =
      TicketInstance
      |> Ash.Query.for_read(:read, %{}, actor: user)
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
