defmodule GitsWeb.UserController do
  use GitsWeb, :controller
  require Ash.Query

  alias Gits.Auth.User
  alias Gits.Storefront.TicketInstance

  def events(conn, _) do
    conn
    |> render(:events)
  end

  def ticket(conn, params) do
    TicketInstance
    |> Ash.Query.for_read(:qr_code, %{token: params["token"]})
    |> Ash.Query.load([:ticket_name, :event_name])
    |> Ash.read_one()
    |> case do
      {:ok, %TicketInstance{} = instance} ->
        time_zone = Application.get_env(:gits, :time_zone)

        conn
        |> assign(:ticket_name, instance.ticket_name)
        |> assign(:event_name, instance.event_name)
        |> assign(:token, params["token"])

      _ ->
        conn |> assign(:token, nil)
    end
    # |> put_layout(false)
    |> render(:ticket)
  end

  def tickets(conn, _) do
    user =
      conn.assigns.current_user

    user
    |> load_user_with_tickets()
    |> case do
      {:ok, %User{customer: customer}} ->
        conn
        |> assign(:instances, customer.instances)
        |> render(:tickets)

      _ ->
        conn |> redirect(to: ~p"/sign-in?return_to=/my/tickets")
    end
  end

  defp load_user_with_tickets(user) do
    Ash.load(
      user,
      [
        customer: [
          instances:
            TicketInstance
            |> Ash.Query.filter(state in [:ready_for_use])
            |> Ash.Query.load([:qr_code, ticket: [event: :address]])
        ]
      ],
      actor: user
    )
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
