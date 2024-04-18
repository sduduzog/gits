defmodule GitsWeb.EventController do
  use GitsWeb, :controller
  require Ash.Query
  alias Gits.Dashboard.Member
  alias Gits.Dashboard.Account
  alias Gits.Storefront.Event
  alias AshPhoenix.Form

  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  def index(conn, _params) do
    events =
      Ash.Query.for_read(Event, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.sort(created_at: :desc)
      |> Ash.read!()

    conn = assign(conn, :events, events)

    render(conn, :index)
  end

  def show(conn, params) do
    event =
      Ash.Query.for_read(Event, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(id: params["id"])
      |> Ash.Query.load(:masked_id)
      |> Ash.read_one!()

    unless event do
      raise GitsWeb.Exceptions.NotFound
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
    members = Ash.Query.filter(Member, user.id == ^conn.assigns.current_user.id)

    account =
      Ash.get!(Account, params["account_id"], actor: conn.assigns.current_user)
      |> Ash.load!(members: members)

    form =
      Form.for_create(Event, :create, as: "event", actor: conn.assigns.current_user)
      |> Form.validate(Map.merge(params["event"], %{account: account}))

    with true <- form.valid?, {:ok, event} <- Form.submit(form) do
      conn
      |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{event.id}/settings")
    else
      error ->
        IO.inspect(error)

        assign(conn, :form, form)
        |> render(:new)
    end

    # Form.for_create(Event, :create, as: "event", actor: conn.assigns.current_user)
    # |> Form.validate(
    #   Map.merge(params["event"], %{
    #     "account" =>
    #       Ash.Query.for_read(Account, :read)
    #       |> Ash.Query.filter(id: params["account_id"])
    #       |> Ash.read_one!()
    #   })
    # )
    # |> case do
    #   form when form.valid? ->
    #     with {:ok, event} <- Form.submit(form) do
    #     else
    #       {:error, _} ->
    #         conn
    #         |> assign(:form, form)
    #         |> put_flash(:error, "Couldn't create event")
    #         |> render(:new, layout: {GitsWeb.Layouts, :event})
    #     end
    #
    #   form ->
    #     conn
    #     |> assign(:form, form)
    #     |> render(:new)
    # end
  end

  def settings(conn, params) do
    event =
      Ash.Query.for_read(Event, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(id: params["event_id"])
      |> Ash.Query.load(:address)
      |> Ash.read_one!()

    unless event do
      raise GitsWeb.Exceptions.NotFound
    end

    listing_image = get_listing_image(params["account_id"], params["event_id"])
    feature_image = get_feature_image(params["account_id"], params["event_id"])

    conn
    |> assign(:event, event)
    |> assign(:listing_image, listing_image)
    |> assign(:feature_image, feature_image)
    |> render(:settings)
  end

  defp get_listing_image(account_id, event_id) do
    filename = "#{account_id}/#{event_id}/listing.jpg"

    ExAws.S3.head_object("gits", filename)
    |> ExAws.request()
    |> case do
      {:ok, _} ->
        "/bucket/#{filename}"

      {:error, _} ->
        nil
    end
  end

  defp get_feature_image(account_id, event_id) do
    filename = "#{account_id}/#{event_id}/feature.jpg"

    ExAws.S3.head_object("gits", filename)
    |> ExAws.request()
    |> case do
      {:ok, _} ->
        "/bucket/#{filename}"

      {:error, _} ->
        nil
    end
  end

  def edit(conn, params) do
    event = Ash.get!(Event, params["id"], actor: conn.assigns.current_user)
    form = Form.for_update(event, :update, as: "event", actor: conn.assigns.current_user)

    assign(conn, :form, form)
    |> render(:edit)
  end

  def update(conn, params) do
    event = Ash.get!(Event, params["id"], actor: conn.assigns.current_user)

    form =
      Form.for_update(event, :update, as: "event", actor: conn.assigns.current_user)
      |> Form.validate(params["event"])

    with true <- form.valid?, {:ok, event} <- Form.submit(form) do
      assign(conn, :form, form)
      |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{event.id}/settings")
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
