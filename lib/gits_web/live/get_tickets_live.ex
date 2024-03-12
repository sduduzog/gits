defmodule GitsWeb.GetTicketsLive do
  use GitsWeb, :live_view
  require Ash.Query
  alias Gits.Events.Event
  alias Gits.Events.Ticket
  alias Gits.Events.TicketInstance

  def mount(%{"id" => event_id}, _session, socket) do
    event =
      Event
      |> Ash.Query.filter(id: event_id)
      |> Gits.Events.read_one!()

    socket =
      socket
      |> assign(:ticket, 0)
      |> assign(:event, event)
      |> assign_tickets(event_id)

    {:ok, socket}
  end

  def handle_event("add_ticket", %{"id" => ticket_id}, socket) do
    ticket =
      Ticket
      |> Ash.Query.filter(id: ticket_id)
      |> Gits.Events.read_one!()
      |> Ash.Changeset.for_update(:add_instance,
        instance: %{user_id: socket.assigns.current_user.id}
      )
      |> Gits.Events.update!()

    {:noreply, assign_tickets(socket, ticket.event_id)}
  end

  def handle_event("remove_ticket", %{"id" => ticket_id}, socket) do
    TicketInstance
    |> Ash.Query.filter(ticket_id: ticket_id, user_id: socket.assigns.current_user.id)
    |> Ash.Query.sort(created_at: :desc)
    |> Gits.Events.read!()
    |> case do
      [first | _] when not is_nil(first) ->
        ticket =
          Ticket
          |> Ash.Query.filter(id: ticket_id)
          |> Gits.Events.read_one!()
          |> Ash.Changeset.for_update(:remove_instance,
            instance: first
          )
          |> Gits.Events.update!()

        {:noreply, assign_tickets(socket, ticket.event_id)}

      _ ->
        {:noreply, socket}
    end
  end

  defp assign_tickets(socket, event_id) do
    tickets =
      Ticket
      |> Ash.Query.filter(event_id: event_id)
      |> Ash.Query.aggregate(:quantity, :count, :ticket_instances,
        query: [filter: [user_id: socket.assigns.current_user.id]]
      )
      |> Gits.Events.read!()

    assign(socket, :tickets, tickets)
  end
end
