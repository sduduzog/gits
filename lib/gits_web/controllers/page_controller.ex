defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Accounts.{Host, User}
  alias Gits.Bucket
  alias Gits.Dashboard.Member
  alias Gits.Documentation
  alias Gits.Storefront.Event

  def home(conn, _) do
    conn
    |> assign(:slug, "/")
    |> assign(:title, "/")
    |> assign(:page_title, "Home")
    |> assign(:current_tab, :home)
    |> render(:home)
  end

  def search(conn, _) do
    events =
      Event
      |> Ash.Query.for_read(:read)
      # |> Ash.Query.filter(starts_at >= fragment("now()") and visibility == :public)
      |> Ash.Query.filter(visibility == :public)
      |> Ash.Query.load([:minimum_ticket_price, :maximum_ticket_price, :address, :masked_id])
      |> Ash.read!(actor: conn.assigns.current_user)

    conn
    |> assign(:events, events)
    |> assign(:current_tab, :search)
    |> assign(:page_title, "Search")
    |> render(:search)
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

  def host(%{assigns: %{current_user: %User{}}} = conn, _) do
    Host
    |> Ash.Query.filter(owner.id == ^conn.assigns.current_user.id)
    |> Ash.read()
    |> case do
      {:ok, [%Host{handle: handle}]} ->
        conn
        |> redirect(to: Routes.host_dashboard_path(conn, :overview, handle))

      _ ->
        conn
        |> render(:host)
    end
  end

  def host(conn, _) do
    conn
    |> render(:host)
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
    conn
    |> assign(:article, Documentation.Articles.get_article_by_id!("privacy"))
    |> render(:article)
  end

  def terms(conn, _params) do
    conn
    |> assign(:article, Documentation.Articles.get_article_by_id!("terms"))
    |> render(:article)
  end

  def contact_us(conn, _params) do
    conn
    |> assign(:article, Documentation.Articles.get_article_by_id!("contact-us"))
    |> render(:article)
  end

  def help(conn, _params) do
    render(conn, :help)
  end

  def assets(conn, params) do
    conn |> redirect(external: Bucket.get_image_url(params["filename"]))
  end

  def healthz(conn, _) do
    conn |> json(%{hello: "world"})
  end
end
