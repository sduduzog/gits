defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Storefront.Customer
  alias Gits.Dashboard.Member
  alias Gits.Storefront.Event

  def home(conn, _params) do
    # ExAws.S3.list_buckets() |> ExAws.request!() |> IO.inspect()

    events =
      Ash.Query.for_read(Event, :masked, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.load([:minimum_ticket_price, :masked_id, :address, :ticket_price_varies])
      |> Ash.read!()

    conn
    |> put_layout(false)
    |> assign(:events, events)
    |> render(:home)
  end

  def organizers(conn, _) do
    membership_exists?(conn)
    |> case do
      true -> redirect(conn, to: "/accounts")
      _ -> conn |> put_layout(false) |> render(:organizers) |> halt()
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
    customer =
      Ash.Query.for_read(Customer, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(user.id == ^conn.assigns.current_user.id)
      |> Ash.Query.load(
        scannable_instances: [:event_name, :ticket_name, :event_starts_at, :event_address]
      )
      |> Ash.read_one!()

    conn |> assign(:customer, customer) |> render(:tickets)
  end

  def search(conn, _params) do
    render(conn, :search)
  end

  def bucket(conn, params) do
    bucket_name = Application.get_env(:gits, :bucket_name)
    filename = Enum.join(params["keys"], "/")

    ExAws.S3.head_object(bucket_name, filename)
    |> ExAws.request()
    |> case do
      {:ok, _} ->
        response =
          ExAws.S3.get_object(bucket_name, filename)
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
