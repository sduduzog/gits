defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Bucket
  alias Gits.Dashboard.Member
  alias Gits.Documentation
  alias Gits.Storefront.Event

  def home(conn, _) do
    events =
      Event
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(starts_at >= fragment("now()") and visibility == :public)
      |> Ash.Query.load([:minimum_ticket_price, :maximum_ticket_price, :address, :masked_id])
      |> Ash.read!(actor: conn.assigns.current_user)

    conn
    |> assign(:slug, "/")
    |> assign(:title, "/")
    |> assign(:events, events)
    |> render(:home, layout: false)
  end

  def events(conn, _) do
    events =
      Event
      |> Ash.Query.for_read(:read, %{}, actor: conn.assigns.current_user)
      |> Ash.read!()

    conn
    |> assign(:events, events)
    |> render(:events)
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
      |> render(:organizers)
    end
  end

  def faq(conn, _) do
    faqs = Documentation.Faqs.all_faqs()

    conn
    |> assign(:faqs, faqs)
    |> render(:faq)
  end

  def privacy(conn, _params) do
    render(conn, :privacy)
  end

  def search(conn, _params) do
    render(conn, :search)
  end

  def assets(conn, params) do
    conn |> redirect(external: Bucket.get_image_url(params["filename"]))
  end

  def healthz(conn, _) do
    time_zone = Application.get_env(:gits, :time_zone)
    {:ok, datetime} = NaiveDateTime.local_now() |> DateTime.from_naive(time_zone)

    conn |> json(%{datetime: datetime})
  end
end
