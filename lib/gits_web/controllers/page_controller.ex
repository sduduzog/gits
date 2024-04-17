defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Dashboard.Member
  alias Gits.Storefront.Event

  def home(conn, _params) do
    events =
      Ash.Query.for_read(Event, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.load([:minimum_ticket_price, :masked_id, :address])
      |> Ash.read!()

    conn
    |> assign(:events, events)
    |> render(:home)
  end

  def organizers(conn, _) do
    membership_exists?(conn)
    |> case do
      true -> redirect(conn, to: "/accounts")
      _ -> render(conn, :organizers) |> halt()
    end
  end

  defp membership_exists?(conn) do
    conn.assigns.current_user
    |> case do
      user when not is_nil(user) ->
        Member
        |> Ash.Query.filter(user.id == ^conn.assigns.current_user.id)
        |> Ash.exists?(actor: conn.assigns.current_user)

      nil ->
        false
    end
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

  def bucket(conn, params) do
    filename = Enum.join(params["keys"], "/")

    ExAws.S3.head_object("gits", filename)
    |> ExAws.request()
    |> case do
      {:ok, _} ->
        response =
          ExAws.S3.get_object("gits", filename)
          |> ExAws.request!()

        {_, etag} = Enum.find(response.headers, fn {key, _} -> key == "ETag" end)
        {_, content_type} = Enum.find(response.headers, fn {key, _} -> key == "Content-Type" end)

        {_, last_modified} =
          Enum.find(response.headers, fn {key, _} -> key == "Last-Modified" end)

        conn
        |> put_resp_header("ETag", etag)
        |> put_resp_header("Content-Type", content_type)
        |> put_resp_header("Last-Modified", last_modified)
        |> send_resp(:ok, response.body)

      {:error, _} ->
        nil
    end
  end
end
