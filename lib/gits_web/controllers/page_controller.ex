defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Storefront.Customer
  alias Gits.Dashboard.Member
  alias Gits.Storefront.Event

  def home(conn, _params) do
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
      if conn.assigns.current_user do
        Ash.Query.for_read(Customer, :read, %{}, actor: conn.assigns.current_user)
        |> Ash.Query.filter(user.id == ^conn.assigns.current_user.id)
        |> Ash.Query.load(
          scannable_instances: [:event_name, :ticket_name, :event_starts_at, :event_address]
        )
        |> Ash.read_one!()
      else
        nil
      end

    conn =
      unless customer do
        put_layout(conn, false)
      else
        conn
      end

    conn |> assign(:customer, customer) |> render(:tickets)
  end

  def search(conn, _params) do
    render(conn, :search)
  end

  def bucket(conn, params) do
    bucket_name = Application.get_env(:gits, :bucket_name)
    filename = Enum.join(params["keys"], "/")

    with {:ok, _} <-
           ExAws.S3.head_object(bucket_name, filename)
           |> ExAws.request(),
         {:ok, url} <- get_presigned_url(bucket_name, filename) do
      redirect(conn, external: url)
    else
      {:error, _} ->
        nil
    end
  end

  defp get_presigned_url(bucket_name, filename) do
    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, bucket_name, filename, [])
  end
end
