defmodule GitsWeb.EventController do
  use GitsWeb, :controller
  require Ash.Query
  alias AshPhoenix.Form
  alias Gits.Events
  alias Gits.Events.Event

  plug :assign_params

  def assign_params(conn, _) do
    with [_, account_id, _, event_id] <- conn.path_info do
      conn
      |> assign(:account_id, account_id)
      |> assign(:event_id, event_id)
    else
      _ ->
        conn
    end
  end

  def index(conn, _) do
    text(conn, "Hello")
  end

  def show(conn, %{"id" => event_id}) do
    Event
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id == ^event_id)
    |> Gits.Events.read_one!()
    |> IO.inspect()

    conn
    |> render(:show, layout: {GitsWeb.Layouts, :event})
  end

  def new(conn, _) do
    conn
    |> assign(
      :form,
      Form.for_create(Event, :create, api: Events, as: "event")
    )
    |> render(:new, layout: {GitsWeb.Layouts, :event})
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
end
