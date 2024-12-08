defmodule GitsWeb.StorefrontLive.EventOrder do
  require Ash.Query
  require Decimal
  alias Gits.Storefront.{Order, Ticket, TicketType}
  alias AshPhoenix.Form
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    Order
    |> Ash.get(params["order_id"], load: [:event], actor: user)
    |> case do
      {:ok, order} ->
        socket
        |> assign(:page_title, order.event.name)
        |> assign(:event_name, order.event.name)
        |> assign_order_update(order, user)
        |> ok()

      {:error, _} ->
        socket
        |> assign(:page_title, "Not found")
        |> ok(:not_found)
    end
  end

  def handle_event("open", unsigned_params, socket) do
    socket.assigns.open_form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign_order_update(order, socket.assigns.current_user)
        |> noreply()
    end
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    socket.assigns.remove_ticket_form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign_order_update(order, socket.assigns.current_user)
    end
    |> noreply
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    socket.assigns.add_ticket_form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign_order_update(order, socket.assigns.current_user)
    end
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(
      :process_form,
      socket.assigns.process_form |> Form.validate(unsigned_params["form"])
    )
    |> noreply()
  end

  def handle_event("process", unsigned_params, socket) do
    socket.assigns.process_form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign_order_update(order, socket.assigns.current_user)
    end
    |> noreply
  end

  def handle_event("reopen", unsigned_params, socket) do
    socket.assigns.reopen_form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign_order_update(order, socket.assigns.current_user)
    end
    |> noreply()
  end

  def handle_event("confirm", unsigned_params, socket) do
    socket.assigns.confirm_form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, %Order{state: :completed} = order} ->
        socket
        |> assign_order_update(order, socket.assigns.current_user)

      {:ok, %Order{paystack_authorization_url: url}} ->
        socket |> redirect(external: url)
    end
    |> noreply()
  end

  def assign_order_update(socket, order, actor) do
    assign(socket, :order_state, order.state)
    |> assign(:order_id, order.id)
    |> assign(:order_email, order.email)
    |> assign_forms(order, actor)
    |> assign_ticket_types(order, actor)
  end

  def assign_forms(socket, order, actor) do
    case order.state do
      :anonymous ->
        assign(socket, :open_form, Form.for_update(order, :open))

      :open ->
        socket
        |> assign(
          :remove_ticket_form,
          Form.for_update(order, :remove_ticket, forms: [auto?: true], actor: actor)
          |> Form.add_form([:ticket_type], type: :update)
          |> Form.add_form([:ticket_type, :ticket], type: :update)
        )
        |> assign(
          :add_ticket_form,
          Form.for_update(order, :add_ticket, forms: [auto?: true], actor: actor)
          |> Form.add_form([:ticket_type], type: :update)
          |> Form.add_form([:ticket_type, :ticket], type: :create)
          |> Form.add_form([:ticket_type, :ticket, :order], type: :read)
        )
        |> assign(:process_form, Form.for_update(order, :process, actor: actor))

      :processed ->
        socket
        |> assign(:reopen_form, order |> Form.for_update(:reopen, actor: actor))
        |> assign(:confirm_form, order |> Form.for_update(:confirm, actor: actor))

      :confirmed ->
        socket

      :completed ->
        socket
    end
  end

  def assign_ticket_types(socket, order, user) do
    Ash.load(
      order,
      [event: [ticket_types: [tickets: Ash.Query.filter(Ticket, order.id == ^order.id)]]],
      actor: user
    )
    |> case do
      {:ok, order} ->
        event = order.event

        ticket_types =
          Enum.map(event.ticket_types, fn type ->
            {type.id, type.name, type.price, type.color, type.tickets}
          end)

        total =
          Enum.reduce(event.ticket_types, Decimal.new("0"), fn cur, acc ->
            cur.price |> Decimal.mult(Enum.count(cur.tickets)) |> Decimal.add(acc)
          end)

        assign(socket, :total, total)
        |> assign(:ticket_types, ticket_types)
    end
  end
end
