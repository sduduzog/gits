defmodule GitsWeb.TicketsLive do
  require Ash.Query
  alias Gits.Storefront.Customer
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    customer =
      Ash.Query.for_read(Customer, :read, %{}, actor: socket.assigns.current_user)
      |> Ash.Query.filter(user.id == ^socket.assigns.current_user.id)
      |> Ash.Query.load(tickets: [:instance_id, :event_name, :event_starts_at, :event_address])
      |> Ash.read_one!()
      |> IO.inspect()

    socket =
      socket
      |> assign(:tickets, customer.tickets)

    {:ok, socket}
  end
end
