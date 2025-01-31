defmodule GitsWeb.PageController do
  require Ash.Sort
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Accounts.{Host, User}
  alias Gits.Dashboard.Member
  alias Gits.Storefront.Event

  def home(conn, _) do
    viewer_id =
      get_session(conn, :viewer_id)

    recent_events =
      Ash.Query.for_read(Event, :read)
      |> Ash.Query.filter(interactions.viewer_id == ^viewer_id)
      |> Ash.Query.load([
        :venue,
        :host,
        :minimum_ticket_price,
        :ticket_prices_vary?,
        poster: [:url]
      ])
      |> Ash.Query.sort([{Ash.Sort.expr_sort(interactions.created_at), :desc}])
      |> Ash.Query.limit(3)
      |> Ash.read()
      |> case do
        {:ok, events} -> events
        _ -> []
      end

    conn
    |> assign(:slug, "/")
    |> assign(:title, "/")
    |> assign(:page_title, "Home")
    |> assign(:current_tab, :home)
    |> assign(:recent_events, recent_events)
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
        |> redirect(to: Routes.host_dashboard_path(conn, :home, handle))

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

  def pricing(conn, _) do
    render(conn, :pricing)
  end

  def faqs(conn, params) do
    {token, version, cv} =
      case params do
        %{"_storyblok_tk" => %{"timestamp" => cv}} ->
          token =
            Application.get_env(:gits, :storyblok)
            |> Keyword.get(:preview_token)

          {token, "draft", cv}

        _ ->
          token =
            Application.get_env(:gits, :storyblok)
            |> Keyword.get(:public_token)

          ts =
            DateTime.to_unix(DateTime.utc_now(), :millisecond)
            |> to_string()

          {token, "published", ts}
      end

    Req.get(
      "https://api.storyblok.com/v2/cdn/stories/faqs?token=#{token}&version=#{version}&cv=#{cv}"
    )
    |> case do
      {:ok, %{body: %{"story" => %{"content" => %{"body" => faqs}}}}} ->
        conn
        |> assign(:faqs, faqs)
        |> render(:faq)
    end
  end

  def healthz(conn, _) do
    conn |> json(%{hello: "world"})
  end
end
