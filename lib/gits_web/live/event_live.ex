defmodule GitsWeb.EventLive do
  alias Gits.Storefront.Basket
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

  def handle_event("clear_basket", _, socket) do
    socket =
      if Map.has_key?(socket.assigns, :basket) and socket.assigns.basket != nil do
        socket.assigns.basket
        |> Ash.Changeset.for_update(:abandon, %{}, actor: socket.assigns.current_user)
        |> Ash.update!()

        socket |> assign(:basket, nil)
      else
        socket
      end

    reload(socket)
  end

  def handle_event("settle_basket", _unsigned_params, socket) do
    socket =
      socket
      |> assign_new(:basket, fn assigns ->
        user = assigns.current_user
        customer = assigns.customer

        Basket
        |> Ash.Changeset.for_create(
          :create,
          %{
            amount: customer.tickets_total_price,
            instances: Enum.map(customer.instances, fn instance -> instance.id end)
          },
          actor: user
        )
        |> Ash.create!()
      end)

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
        tickets_total_price: [event_id: event.id],
        tickets_count: [event_id: event.id],
        instances:
          TicketInstance
          |> Ash.Query.for_read(:read, %{}, actor: user)
          |> Ash.Query.filter(ticket.event.id == ^event.id)
          |> Ash.Query.filter(state == :reserved)
      )

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
