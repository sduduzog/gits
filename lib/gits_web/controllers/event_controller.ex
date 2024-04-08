defmodule GitsWeb.EventController do
  use GitsWeb, :controller
  require Ash.Query
  alias Gits.Dashboard.Account
  alias Gits.Dashboard.Event
  alias AshPhoenix.Form

  plug :assign_params
  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

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

  def index(conn, params) do
    assign(
      conn,
      :events,
      Ash.Query.filter(Event, account.id == ^params["account_id"])
      |> Ash.Query.sort(created_at: :desc)
      |> Ash.read!()
    )
    |> render(:index)
  end

  def show(conn, params) do
    conn
    |> assign(
      :event,
      Ash.Query.for_read(Event, :read)
      |> Ash.Query.filter(id: params["id"])
      |> Ash.read_one!()
    )
    |> render(:show)
  end

  def new(conn, _) do
    assign(
      conn,
      :form,
      Form.for_create(Event, :create, as: "event", actor: conn.assigns.current_user)
    )
    |> render(:new)
  end

  def create(conn, params) do
    Form.for_create(Event, :create, as: "event", actor: conn.assigns.current_user)
    |> Form.validate(
      Map.merge(params["event"], %{
        "account" =>
          Ash.Query.for_read(Account, :read)
          |> Ash.Query.filter(id: params["account_id"])
          |> Ash.read_one!()
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
        |> render(:new)
    end
  end

  def settings(conn, params) do
    event =
      Event
      |> Ash.Query.filter(id: params["event_id"])
      |> Ash.read_one!()

    conn
    |> assign(:event, event)
    |> render(:settings)
  end

  def edit(conn, params) do
    assign(
      conn,
      :form,
      Form.for_update(
        Event
        |> Ash.Query.filter(id: params["id"])
        |> Ash.read_one!(),
        :update,
        as: "event",
        actor: conn.assigns.current_user
      )
    )
    |> render(:edit)
  end

  def update(conn, params) do
    Form.for_update(
      Event
      |> Ash.Query.filter(id: params["id"])
      |> Ash.read_one!(),
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
            |> render(:edit)
        end

      form ->
        conn
        |> assign(:form, form)
        |> render(:edit)
    end
  end
end
