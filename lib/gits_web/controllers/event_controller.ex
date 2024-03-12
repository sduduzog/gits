defmodule GitsWeb.EventController do
  use GitsWeb, :controller
  require Ash.Query
  alias AshPhoenix.Form
  alias Gits.Events
  alias Gits.Events.Event

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

  def show(conn, %{"id" => event_id}) do
    conn
    |> assign(:event, event_id)
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
      Form.for_create(Event, :create, api: Events, as: "event")
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
    form =
      Form.for_create(Event, :create, api: Events, as: "event")
      |> Form.validate(params["event"])

    with true <- form.valid?, {:ok, event} <- Form.submit(form) do
      conn
      |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{event.id}")
    else
      _ ->
        conn
        |> assign(:form, form)
        |> render(:new, layout: {GitsWeb.Layouts, :event})
    end
  end

  def update(conn, params) do
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
      |> IO.inspect()
    )
    |> render(:edit, layout: {GitsWeb.Layouts, :event})
  end
end
