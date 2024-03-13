defmodule GitsWeb.TicketController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Events.Event
  alias Gits.Events
  alias Gits.Events.Ticket
  alias AshPhoenix.Form

  plug :assign_params

  def assign_params(%{path_info: [_, account_id, _, event_id, _]} = conn, _) do
    conn
    |> assign(:account_id, account_id)
    |> assign(:event_id, event_id)
  end

  def assign_params(%{path_info: [_, account_id, _, event_id, _, ticket_id | _tail]} = conn, _) do
    unless ticket_id == "new" do
      conn
      |> assign(:account_id, account_id)
      |> assign(:event_id, event_id)
      |> assign(:ticket_id, ticket_id)
    else
      conn
      |> assign(:account_id, account_id)
      |> assign(:event_id, event_id)
    end
  end

  def assign_params(conn, _) do
    conn
  end

  def index(conn, params) do
    tickets =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(event_id: params["event_id"])
      |> Gits.Events.read!()

    conn
    |> assign(:tickets, tickets)
    |> render(:index, layout: {GitsWeb.Layouts, :event})
  end

  def new(conn, _) do
    conn
    |> assign(
      :form,
      Form.for_create(Ticket, :create, api: Events, as: "ticket")
    )
    |> render(:new, layout: {GitsWeb.Layouts, :event})
  end

  def create(conn, params) do
    form =
      Form.for_create(Ticket, :create,
        api: Events,
        as: "ticket",
        actor: conn.assigns.current_user
      )
      |> Form.validate(
        Map.merge(params["ticket"], %{
          "event" =>
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(id: params["event_id"])
            |> Gits.Events.read_one!()
        })
      )

    with true <- form.valid?, {:ok, ticket} <- Form.submit(form) do
      conn
      |> redirect(
        to:
          ~p"/accounts/#{params["account_id"]}/events/#{params["event_id"]}/tickets/#{ticket.id}"
      )
    else
      _ ->
        conn
        |> assign(:form, form)
        |> render(:new, layout: {GitsWeb.Layouts, :event})
    end
  end

  def show(conn, params) do
    ticket =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id: params["id"], event_id: params["event_id"])
      |> Gits.Events.read_one!()

    conn
    |> assign(:ticket, ticket)
    |> render(:show, layout: {GitsWeb.Layouts, :ticket})
  end

  def edit(conn, %{"id" => ticket_id} = _params) do
    ticket =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id: ticket_id)
      |> Gits.Events.read_one!()

    conn
    |> assign(:ticket, ticket)
    |> assign(:form, Form.for_update(ticket, :update, api: Events, as: "ticket"))
    |> render(:edit, layout: {GitsWeb.Layouts, :ticket})
  end

  def update(conn, %{"id" => ticket_id} = params) do
    ticket =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id: ticket_id)
      |> Gits.Events.read_one!()

    form =
      Form.for_update(ticket, :update,
        api: Events,
        as: "ticket"
      )
      |> Form.validate(params["ticket"])

    with true <- form.valid?, {:ok, ticket} <- Form.submit(form) do
      conn
      |> redirect(
        to:
          ~p"/accounts/#{params["account_id"]}/events/#{params["event_id"]}/tickets/#{ticket.id}"
      )
    else
      _ ->
        conn
        |> assign(:form, form)
        |> render(:edit, layout: {GitsWeb.Layouts, :event})
    end

    conn
    |> assign(:ticket, ticket)
    |> assign(:form, form)
    |> render(:edit, layout: {GitsWeb.Layouts, :ticket})
  end
end
