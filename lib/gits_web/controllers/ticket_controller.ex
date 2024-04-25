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
      |> Ash.Query.for_read(:read, %{}, actor: conn.assigns.current_user)
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
    event = Ash.get!(Event, params["event_id"], actor: conn.assigns.current_user)

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
    user = conn.assigns.current_user

    ticket =
      Ticket
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(id: params["id"], event_id: params["event_id"])
      |> Ash.read_one!()

    conn
    |> assign(:ticket, ticket)
    |> render(:show)
  end

  def edit(conn, %{"id" => ticket_id} = _params) do
    user = conn.assigns.current_user

    ticket =
      Ticket
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(id: ticket_id)
      |> Ash.read_one!()

    conn
    |> assign(:ticket, ticket)
    |> assign(
      :form,
      Form.for_update(ticket, :update, as: "ticket", actor: user)
    )
    |> render(:edit)
  end

  def update(conn, %{"id" => ticket_id} = params) do
    user = conn.assigns.current_user

    ticket =
      Ticket
      |> Ash.get!(ticket_id, actor: user)

    form =
      Form.for_update(ticket, :update,
        api: Events,
        as: "ticket",
        actor: user
      )
      |> Form.validate(params["ticket"])

    with true <- form.valid?, {:ok, ticket} <- Form.submit(form) do
      conn
      |> redirect(
        to:
          ~p"/accounts/#{params["account_id"]}/events/#{params["event_id"]}/tickets/#{ticket.id}"
      )
    else
      foo ->
        IO.inspect(foo)

        conn
        |> assign(:form, form)
        |> render(:edit)
    end
  end

  def delete(conn, params) do
    Ash.get!(Ticket, params["id"])
    |> Ash.destroy!(actor: conn.assigns.current_user)

    conn
    |> redirect(to: ~p"/accounts/#{params["account_id"]}/events/#{params["event_id"]}/tickets")
  end
end
