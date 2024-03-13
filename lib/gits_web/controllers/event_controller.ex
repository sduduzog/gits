defmodule GitsWeb.EventController do
  use GitsWeb, :controller
  require Ash.Query
  alias AshPhoenix.Form
  alias Gits.Events
  alias Gits.Events.Event
  alias Gits.Accounts.Account

  plug :assign_params

  def assign_params(conn, _) do
    case conn.path_info do
      [_, account_id, _, event_id | _] ->
        conn
        |> assign(:account_id, account_id)
        |> assign(:event_id, event_id)

      [_, account_id, _] ->
        conn
        |> assign(:account_id, account_id)

      _ ->
        conn
    end
  end

  def index(conn, _) do
    text(conn, "Hello")
  end

  def show(conn, params) do
    conn
    |> assign(
      :event,
      Event
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id: params["id"])
      |> Gits.Events.read_one!()
    )
    |> render(:show, layout: {GitsWeb.Layouts, :event})
  end

  def settings(conn, params) do
    event =
      Event
      |> Ash.Query.filter(id: params["event_id"])
      |> Gits.Events.read_one!()

    conn
    |> assign(:event, event)
    |> render(:settings, layout: {GitsWeb.Layouts, :event})
  end

  def new(conn, _) do
    conn
    |> assign(
      :form,
      Form.for_create(Event, :create, api: Events, as: "event", actor: conn.assigns.current_user)
    )
    |> render(:new, layout: {GitsWeb.Layouts, :event})
  end

  def edit(conn, params) do
    conn
    |> assign(
      :form,
      Form.for_update(
        Event
        |> Ash.Query.filter(id: params["id"])
        |> Gits.Events.read_one!(),
        :update,
        api: Events,
        as: "event"
      )
    )
    |> render(:edit, layout: {GitsWeb.Layouts, :event})
  end

  def create(conn, params) do
    Form.for_create(Event, :create, api: Events, as: "event", actor: conn.assigns.current_user)
    |> Form.validate(
      Map.merge(params["event"], %{
        "account" =>
          Account
          |> Ash.Query.for_read(:read)
          |> Ash.Query.filter(id: params["account_id"])
          |> Gits.Accounts.read_one!()
      })
    )
    |> case do
      form when form.valid? ->
        with {:ok, event} <- Form.submit(form) do
          conn
          |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{event.id}/settings")
        else
          {:error, _} ->
            conn
            |> assign(:form, form)
            |> put_flash(:error, "Couldn't create event")
            |> render(:new, layout: {GitsWeb.Layouts, :event})
        end

      form ->
        conn
        |> assign(:form, form)
        |> render(:new, layout: {GitsWeb.Layouts, :event})
    end
  end

  def update(conn, params) do
    Form.for_update(
      Event
      |> Ash.Query.filter(id: params["id"])
      |> Gits.Events.read_one!(),
      :update,
      api: Events,
      as: "event"
    )
    |> Form.validate(params["event"])
    |> case do
      form when form.valid? ->
        with {:ok, event} <- Form.submit(form) do
          conn
          |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{event.id}/settings")
        else
          _ ->
            conn
            |> assign(:form, form)
            |> render(:edit, layout: {GitsWeb.Layouts, :event})
        end

      form ->
        conn
        |> assign(:form, form)
        |> render(:edit, layout: {GitsWeb.Layouts, :event})
    end
  end
end
