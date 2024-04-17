defmodule GitsWeb.TicketsLive do
  require Ash.Query
  alias Gits.Storefront.TicketInstance
  alias Gits.Storefront.Customer
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    customer =
      Ash.Query.for_read(Customer, :read)
      |> Ash.Query.filter(user.id == ^socket.assigns.current_user.id)
      |> Ash.Query.load(
        instances:
          Ash.Query.for_read(TicketInstance, :read)
          |> Ash.Query.load([:ticket_name, :event_name, :event_starts_at, :event_address])
      )
      |> Ash.read_one!(actor: socket.assigns.current_user)

    socket =
      assign(socket, :ticket_instances, [
        %{
          id: "a",
          ticket: %{name: "Ticket", event: %{name: "event name", starts_at: DateTime.utc_now()}}
        }
      ])
      |> assign(:instances, customer.instances)

    {:ok, socket}
  end
end
