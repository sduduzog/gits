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
    |> assign(:events, events)
    |> render(:home)
  end

  def organizers(conn, _) do
    member =
      if conn.assigns.current_user do
        Member
        |> Ash.Query.for_read(:read, %{}, actor: conn.assigns.current_user)
        |> Ash.Query.filter(user.id == ^conn.assigns.current_user.id)
        |> Ash.Query.load(:account)
        |> Ash.Query.load(:waitlisted)
        |> Ash.Query.limit(1)
        |> Ash.read_one!()
      else
        nil
      end

    if not is_nil(member) and not is_nil(member.account) do
      redirect(conn, to: "/accounts")
    else
      conn = assign(conn, :member, member)

      conn
      |> put_layout(html: :thin)
      |> render(:organizers)
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
        |> Ash.read_one!()
        |> IO.inspect()
      else
        nil
      end

    customer =
      if not is_nil(customer) do
        customer
        |> Ash.load!(
          [scannable_instances: [:event_name, :ticket_name, :event_starts_at, :event_address]],
          actor: customer
        )
      else
        customer
      end

    conn |> assign(:customer, customer) |> render(:tickets)
  end

  def faq(conn, _) do
    conn
    |> assign(:faqs, [
      %{
        q: "Can I print my ticket?",
        a:
          "No. The world is digital enough. There's no use downloading or printing the ticket when you're still going to open your phone to get the ticket from your gallery anyways"
      },
      %{
        q: "Where's the rest of GiTS",
        a:
          "We're being careful by how much we release into the wild. The aim is to have the most stable version of gits available to the general public. Until then, we'll just continue releasing enough to get things done. This doesn't stop you from buying a ticket to an event on the platform or creating your own."
      }
    ])
    |> render(:faq)
  end

  def search(conn, _params) do
    render(conn, :search)
  end

  def join_wailtist(conn, _) do
    user = conn.assigns.current_user

    if is_nil(user) do
      redirect(conn, to: "/register?return_to=#{conn.request_path}")
    else
      member =
        Member
        |> Ash.Query.for_read(:read, %{}, actor: conn.assigns.current_user)
        |> Ash.Query.filter(user.id == ^conn.assigns.current_user.id)
        |> Ash.Query.limit(1)
        |> Ash.read_one!()

      if is_nil(member) do
        Member
        |> Ash.Changeset.for_create(:waitlist, %{user: user}, actor: user)
        |> Ash.create!()
      end
    end

    redirect(conn, to: "/organizers")
  end

  def bucket(conn, params) do
    filename = Enum.join(params["keys"], "/")

    with {:ok, _} <-
           check_for_object(filename),
         {:ok, url} <- get_presigned_url(filename) do
      redirect(conn, external: url)
    else
      {:error, _} ->
        nil
    end
  end

  defp check_for_object(filename) do
    bucket_name = Application.get_env(:gits, :bucket_name)

    ExAws.S3.head_object(bucket_name, filename)
    |> ExAws.request()
  end

  defp get_presigned_url(filename) do
    bucket_name = Application.get_env(:gits, :bucket_name)

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, bucket_name, filename, [])
  end
end
