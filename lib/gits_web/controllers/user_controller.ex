defmodule GitsWeb.UserController do
  use GitsWeb, :controller
  require Ash.Query

  alias Gits.Storefront.TicketInstance

  def events(conn, _) do
    conn
    |> render(:events)
  end

  def ticket(conn, params) do
    user =
      conn.assigns.current_user

    TicketInstance
    |> Ash.Query.for_read(:qr_code, %{token: params["token"]}, actor: user)
    |> Ash.Query.load([:qr_code, :ticket_name, :event_name])
    |> Ash.read_one()
    |> case do
      {:ok, %TicketInstance{} = instance} ->
        conn
        |> assign(:ticket_name, instance.ticket_name)
        |> assign(:event_name, instance.event_name)
        |> assign(:share_uri, url(~p"/my/tickets/#{params["token"]}"))
        |> assign(:token, instance.qr_code)

      _ ->
        conn |> assign(:token, nil)
    end
    |> render(:ticket)
  end

  def tickets(conn, _) do
    user =
      conn.assigns.current_user

    TicketInstance
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(state in [:ready_for_use])
    |> Ash.Query.filter(ticket.event.ends_at >= fragment("now()"))
    |> Ash.Query.load([:qr_code, ticket: [event: :address]])
    |> Ash.read(actor: user)
    |> case do
      {:ok, instances} ->
        conn
        |> assign(:instances, instances)
        |> assign(:current_tab, :tickets)
        |> assign(:page_title, "Tickets")
        |> render(:tickets)

      _ ->
        conn |> redirect(to: ~p"/sign-in?return_to=/my/tickets")
    end
  end

  def profile(conn, _) do
    conn
    |> assign(:current_tab, :profile)
    |> assign(:page_title, "Profile")
    |> render(:profile)
  end

  def settings(conn, _) do
    conn
    |> render(:settings)
  end
end
