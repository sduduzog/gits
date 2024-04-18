defmodule GitsWeb.EventLive do
  alias Gits.Storefront.Customer
  alias Gits.Storefront.TicketInstance
  alias Gits.Storefront.Ticket
  use GitsWeb, :live_view
  require Ash.Query
  alias Gits.Storefront.Event

  def mount(params, _, socket) do
    customer =
      case socket.assigns.current_user do
        user when is_struct(user) ->
          Ash.Changeset.for_create(Customer, :create, %{user_id: user.id}, actor: user)
          |> Ash.create!()

        nil ->
          nil
      end

    event =
      Ash.Query.for_read(Event, :masked, %{id: params["id"]}, actor: customer)
      |> Ash.Query.load([:address])
      |> Ash.read_one!()

    unless event do
      raise GitsWeb.Exceptions.NotFound
    end

    socket =
      socket
      |> assign(:customer, customer)
      |> assign(:event, event)

    reload(socket, true)
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_event("continue", _unsigned_params, socket) do
    socket = assign(socket, :summarise, true)
    {:noreply, socket}
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    user = socket.assigns.current_user

    Ash.Query.for_read(TicketInstance, :read, %{}, actor: user)
    |> Ash.Query.filter(ticket.id == ^unsigned_params["id"])
    |> Ash.Query.limit(1)
    |> Ash.read_one!()
    |> Ash.destroy!(actor: user)

    reload(socket)
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    case socket.assigns.current_user do
      user when is_struct(user) ->
        ticket = Ash.get!(Ticket, unsigned_params["id"])
        customer = socket.assigns.customer

        Ash.Changeset.for_create(
          TicketInstance,
          :create,
          %{
            ticket: ticket,
            customer: customer
          },
          actor: user
        )
        |> Ash.create!()

        reload(socket)

      nil ->
        {:noreply,
         redirect(socket,
           to: ~p"/register?return_to=#{~p"/events/#{socket.assigns.event.masked_id}"}"
         )}
    end
  end

  defp reload(socket, initial \\ false) do
    user = socket.assigns.current_user
    customer = socket.assigns.customer
    event = socket.assigns.event

    customer = if initial, do: customer, else: Ash.reload!(customer)

    customer =
      customer
      |> Ash.load!(
        tickets_total: [event_id: event.id],
        tickets_count: [event_id: event.id]
      )
      |> IO.inspect()

    tickets =
      Ash.Query.for_read(Ticket, :read, %{}, actor: user)
      |> Ash.Query.filter(event.id == ^event.id)
      |> Ash.Query.load(:instance_count)
      |> Ash.read!()

    socket =
      socket
      |> assign(:customer, customer)
      |> assign(:tickets, tickets)

    if initial, do: {:ok, socket}, else: {:noreply, socket}
  end

  defp get_feature_image(account_id, event_id) do
    get_image(account_id, event_id, "feature")
  end

  def get_image(account_id, event_id, type) do
    filename = "#{account_id}/#{event_id}/#{type}.jpg"

    ExAws.S3.head_object("gits", filename)
    |> ExAws.request()
    |> case do
      {:ok, _} -> "/bucket/#{filename}"
      _ -> "/images/placeholder.png"
    end
  end
end
