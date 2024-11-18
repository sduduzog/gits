defmodule GitsWeb.StorefrontLive.EventOrder do
  require Ash.Query
  alias Gits.Storefront.{Order, Ticket, TicketType}
  alias AshPhoenix.Form
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    Order
    |> Ash.get(params["order_id"], load: :event)
    |> case do
      {:ok, order} ->
        socket
        |> assign(:page_title, order.event.name)
        |> assign(:event, order.event)
        |> assign(:order, order)
        |> assign_ticket_types()
        |> assign_tickets_summary()
        |> assign_forms()
        |> ok()

      {:error, _} ->
        socket
        |> assign(:page_title, "Not found")
        |> ok(:not_found)
    end
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    socket.assigns.order
    |> Form.for_update(:remove_ticket)
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign_ticket_types()
        |> assign_tickets_summary()
        |> assign_forms()
    end
    |> noreply
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    socket.assigns.order
    |> Form.for_update(:add_ticket)
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign_ticket_types()
        |> assign_tickets_summary()
        |> assign_forms()
    end
    |> noreply
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
        |> assign(:order, order)
        |> assign_ticket_types()
        |> assign_forms()
    end
    |> noreply
  end

  def handle_event("reopen", unsigned_params, socket) do
    socket.assigns.reopen_form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign_ticket_types()
        |> assign_forms()
    end
    |> noreply()
  end

  def handle_event("confirm", unsigned_params, socket) do
    socket.assigns.confirm_form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign_ticket_types()
        |> assign_forms()
    end
    |> noreply
  end

  def assign_forms(socket) do
    order = socket.assigns.order

    case order.state do
      :open ->
        socket
        |> assign(:process_form, order |> Form.for_update(:process))

      :processed ->
        socket
        |> assign(:reopen_form, order |> Form.for_update(:reopen))
        |> assign(:confirm_form, order |> Form.for_update(:confirm))

      :completed ->
        socket
    end
  end

  def assign_ticket_types(socket) do
    Ash.load(socket.assigns.order, [:tickets, :ticket_types])
    |> case do
      {:ok, order} ->
        %{ticket_types: ticket_types, tickets: tickets} = order

        socket
        |> assign(:tickets, tickets)
        |> assign(
          :ticket_types,
          Enum.map(ticket_types, fn type ->
            tickets = Enum.filter(tickets, &(&1.ticket_type_id == type.id))
            count = Enum.count(tickets)

            removable_ticket = tickets |> List.first()

            remove_ticket_form =
              order
              |> Form.for_update(:remove_ticket,
                forms: [
                  auto?: true
                ]
              )

            add_ticket_form =
              order
              |> Form.for_update(:add_ticket,
                forms: [
                  ticket: [
                    resource: Ticket,
                    create_action: :create,
                    update_action: :update,
                    forms: [
                      ticket_type: [
                        resource: TicketType,
                        data: type,
                        create_action: :create,
                        update_action: :update
                      ]
                    ]
                  ]
                ]
              )
              |> Form.add_form([:ticket], params: %{"ticket_type" => %{"id" => type.id}})

            {type.name,
             "Lorem ipsum dolor sit amet consectetur, adipisicing elit. Dignissimos laudantium id provident commodi dicta?",
             "0", count, removable_ticket, remove_ticket_form, add_ticket_form}
          end)
        )
    end
  end

  def assign_tickets_summary(socket) do
    Ash.load(socket.assigns.order, [:tickets, :ticket_types])
    |> case do
      {:ok, order} ->
        %{ticket_types: ticket_types, tickets: tickets} = order

        tickets_summary =
          for type <- ticket_types do
            tickets = Enum.filter(tickets, &(&1.ticket_type_id == type.id))
            count = Enum.count(tickets)

            if count > 0 do
              {type.name, 1 * count, count}
            end
          end

        total =
          for {_, price, _} <- tickets_summary, reduce: 0 do
            acc ->
              acc + price
          end

        socket
        |> assign(:tickets, tickets)
        |> assign(:tickets_summary, tickets_summary)
        |> assign(:tickets_total, total)
    end
  end
end
