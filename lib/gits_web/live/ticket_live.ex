defmodule GitsWeb.TicketLive do
  require Ash.Query
  alias Gits.Storefront.Ticket
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    Ash.Query.filter(Ticket, public_id == ^params["public_id"])
    |> Ash.Query.load(ticket_type: [event: :venue])
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, ticket} ->
        socket
        |> assign(:ticket, %{
          id: ticket.public_id,
          ticket_type: ticket.ticket_type,
          admitted_at: ticket.admitted_at,
          checked_in_at: ticket.checked_in_at,
          attendee: ticket.attendee,
          tags: [
            ticket.public_id,
            to_string(ticket.state)
            |> String.split("_")
            |> Enum.map(&String.capitalize(&1))
            |> Enum.join(" ")
          ]
        })
    end
    |> ok()
  end
end
