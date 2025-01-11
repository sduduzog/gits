defmodule GitsWeb.TicketLive do
  require Ash.Query
  alias AshPhoenix.Form
  alias Gits.Storefront.Ticket
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    Ash.Query.filter(Ticket, public_id == ^params["public_id"])
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, %Ticket{} = ticket} ->
        socket
        |> assign(
          :form,
          Form.for_update(ticket, :rsvp, forms: [auto?: true], actor: socket.assigns.current_user)
          |> Form.add_form([:attendee], type: :read)
        )
        |> assign_ticket(ticket)
        |> ok()

      _ ->
        socket |> ok(:not_found)
    end
  end

  def handle_params(_, _, socket) do
    socket
    |> noreply()
  end

  def handle_event("rsvp", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, ticket} ->
        socket
        |> assign_ticket(ticket)

      {:error, form} ->
        socket |> assign(:form, form)
    end
    |> noreply()
  end

  defp assign_ticket(socket, ticket) do
    Ash.load(ticket, [:attendee, ticket_type: [event: :venue]])
    |> case do
      {:ok, ticket} ->
        socket
        |> assign(:ticket, %{
          id: ticket.public_id,
          ticket_type: ticket.ticket_type,
          admitted_at: ticket.admitted_at,
          rsvp_confirmed_at: ticket.rsvp_confirmed_at,
          attendee: ticket.attendee,
          tags:
            [
              ticket.public_id,
              to_string(ticket.state)
              |> String.split("_")
              |> Enum.map(&String.capitalize(&1))
              |> Enum.join(" "),
              if(ticket.attendee,
                do: "#{ticket.attendee.name} attending",
                else: false
              )
            ]
            |> Enum.filter(& &1)
        })
    end
  end
end
