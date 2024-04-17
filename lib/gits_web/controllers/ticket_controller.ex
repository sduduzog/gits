defmodule GitsWeb.TicketController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Storefront.Event
  alias Gits.Storefront.Ticket
  alias AshPhoenix.Form

  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  def index(conn, params) do
    tickets =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(event_id: params["event_id"])
      |> Ash.read!()

    conn
    |> assign(:tickets, tickets)
    |> render(:index)
  end

  def new(conn, _) do
    conn
    |> assign(
      :form,
      Form.for_create(Ticket, :create,
        as: "ticket",
        actor: conn.assigns.current_user
      )
    )
    |> render(:new)
  end

  def create(conn, params) do
    event = Event |> Ash.get!(params["event_id"])

    form =
      Form.for_create(Ticket, :create,
        as: "ticket",
        actor: conn.assigns.current_user
      )
      |> Form.validate(Map.merge(params["ticket"], %{"event" => event}))

    with true <- form.valid?, {:ok, ticket} <- Form.submit(form) do
      conn
      |> redirect(
        to:
          ~p"/accounts/#{params["account_id"]}/events/#{params["event_id"]}/tickets/#{ticket.id}"
      )
    else
      false ->
        conn
        |> assign(:form, form)
        |> render(:new)

      {:error, _} ->
        conn
        |> assign(:form, form)
        |> render(:new)
    end
  end

  def show(conn, params) do
    ticket =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id: params["id"], event_id: params["event_id"])
      |> Ash.read_one!()

    conn
    |> assign(:ticket, ticket)
    |> render(:show)
  end

  def edit(conn, %{"id" => ticket_id} = _params) do
    ticket =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id: ticket_id)
      |> Ash.read_one!()

    conn
    |> assign(:ticket, ticket)
    |> assign(
      :form,
      Form.for_update(ticket, :update, as: "ticket", actor: conn.assigns.current_user)
    )
    |> render(:edit)
  end

  def update(conn, %{"id" => ticket_id} = params) do
    ticket =
      Ticket
      |> Ash.get!(ticket_id)

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
        |> render(:edit)
    end

    conn
    |> assign(:ticket, ticket)
    |> assign(:form, form)
    |> render(:edit)
  end

  def delete(conn, params) do
    Ash.get!(Ticket, params["id"])
    |> Ash.destroy!(actor: conn.assigns.current_user)

    conn
    |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{params["event_id"]}/tickets")
  end
end
