defmodule GitsWeb.UserController do
  use GitsWeb, :controller
  require Ash.Query

  alias Gits.Storefront.Ticket
  alias Gits.Storefront.TicketInstance

  def events(conn, _) do
    conn
    |> render(:events)
  end

  def ticket(conn, params) do
    user = conn.assigns.current_user

    conn =
      Ticket
      |> Ash.Query.for_read(:with_token, %{token: params["token"]}, actor: user)
      |> Ash.read_one()
      |> case do
        {:ok, ticket} ->
          conn |> assign(:event, ticket.event) |> assign(:token, params["token"])
      end

    conn
    |> put_layout(false)
    |> render(:ticket)
  end

  def tickets(conn, _) do
    user =
      conn.assigns.current_user

    if is_nil(user) do
      raise GitsWeb.Exceptions.NotFound, "no user found"
    end

    tickets =
      Ticket
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(instances.customer.user.id == ^user.id)
      |> Ash.Query.filter(instances.state in [:ready_for_use])
      |> Ash.Query.filter(event.ends_at >= fragment("now()"))
      |> Ash.Query.load([
        :token,
        event: [:address],
        instances:
          TicketInstance
          |> Ash.Query.filter(customer.user.id == ^user.id and state in [:ready_for_use])
      ])
      |> Ash.read!()

    conn
    |> put_layout(false)
    |> assign(:tickets, tickets)
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
