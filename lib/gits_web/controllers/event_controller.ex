defmodule GitsWeb.EventController do
  use GitsWeb, :controller
  alias AshPhoenix.Form
  alias Gits.Events
  alias Gits.Events.Event

  def index(conn, _) do
    text(conn, "Hello")
  end

  def show(conn, _) do
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
