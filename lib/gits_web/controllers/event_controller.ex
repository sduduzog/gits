defmodule GitsWeb.EventController do
  use GitsWeb, :controller
  require Ash.Query
  alias Gits.Dashboard.Account
  alias Gits.Dashboard.Member
  alias Gits.Storefront.Event
  alias AshPhoenix.Form

  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  def index(conn, params) do
    user = conn.assigns.current_user

    member =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(account.id == ^params["account_id"])
      |> Ash.read_one!()

    events =
      Ash.Query.for_read(Event, :read, %{}, actor: member)
      |> Ash.Query.sort(created_at: :desc)
      |> Ash.read!()

    conn = assign(conn, :events, events)

    render(conn, :index)
  end

  def show(conn, params) do
    user = conn.assigns.current_user

    member =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(account.id == ^params["account_id"])
      |> Ash.read_one!()

    event =
      Ash.Query.for_read(Event, :read, %{}, actor: member)
      |> Ash.Query.filter(id: params["id"])
      |> Ash.Query.load(:masked_id)
      |> Ash.read_one!()

    unless event do
      raise GitsWeb.Exceptions.NotFound, "no event found"
    end

    conn
    |> assign(:event, event)
    |> render(:show)
  end

  def new(conn, _) do
    form = Form.for_create(Event, :create, as: "event", actor: conn.assigns.current_user)

    assign(conn, :form, form)
    |> render(:new)
  end

  def create(conn, params) do
    user = conn.assigns.current_user

    account =
      Ash.get!(Account, params["account_id"], actor: user)

    form =
      Form.for_create(Event, :create, as: "event", actor: user)
      |> Form.validate(Map.merge(params["event"], %{account: account}))

    with true <- form.valid?, {:ok, event} <- Form.submit(form) do
      conn
      |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{event.id}/settings")
    else
      _ ->
        assign(conn, :form, form)
        |> render(:new)
    end
  end

  def settings(conn, params) do
    user = conn.assigns.current_user

    member =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(account.id == ^params["account_id"])
      |> Ash.read_one!()

    event =
      Ash.Query.for_read(Event, :read, %{}, actor: member)
      |> Ash.Query.filter(id: params["event_id"])
      |> Ash.Query.load(:address)
      |> Ash.read_one!()

    unless event do
      raise GitsWeb.Exceptions.NotFound, "event not found"
    end

    listing_image = Gits.Bucket.get_listing_image_path(params["account_id"], params["event_id"])
    feature_image = Gits.Bucket.get_feature_image_path(params["account_id"], params["event_id"])

    conn
    |> assign(:event, event)
    |> assign(:listing_image, listing_image)
    |> assign(:feature_image, feature_image)
    |> render(:settings)
  end

  def edit(conn, params) do
    event = Ash.get!(Event, params["id"], actor: conn.assigns.current_user)
    form = Form.for_update(event, :update, as: "event", actor: conn.assigns.current_user)

    assign(conn, :form, form)
    |> render(:edit)
  end

  def update(conn, params) do
    user = conn.assigns.current_user
    event = Ash.get!(Event, params["id"], actor: user)

    form =
      Form.for_update(event, :update, as: "event", actor: user, atomic_upgrade?: false)
      |> Form.validate(params["event"])

    with true <- form.valid? do
      Ash.Changeset.for_update(event, :update, params["event"], actor: user)
      |> Ash.update(atomic_upgrade?: false)
      |> IO.inspect()

      assign(conn, :form, form)
      |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{params["id"]}/settings")
    else
      _ ->
        assign(conn, :form, form)
        |> render(:edit)
    end
  end

  def address(conn, params) do
    conn
    |> put_layout(false)
    |> Phoenix.LiveView.Controller.live_render(
      GitsWeb.EventAddressLive,
      session: %{"params" => params}
    )
  end

  def upload_listing_image(conn, params) do
    conn
    |> put_layout(false)
    |> Phoenix.LiveView.Controller.live_render(
      GitsWeb.UploadListingLive,
      session: %{"params" => params}
    )
  end

  def upload_feature_image(conn, params) do
    conn
    |> put_layout(false)
    |> Phoenix.LiveView.Controller.live_render(
      GitsWeb.UploadFeatureLive,
      session: %{"params" => params}
    )
  end

  def delete(conn, params) do
    Ash.get!(Event, params["id"], actor: conn.assigns.current_user)
    |> Ash.destroy!(actor: conn.assigns.current_user)

    conn |> redirect(to: ~p"/accounts/#{params["account_id"]}/events")
  end
end
