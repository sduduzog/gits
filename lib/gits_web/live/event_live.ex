defmodule GitsWeb.EventLive do
  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.TicketInstance
  alias Gits.Storefront.Ticket
  use GitsWeb, :live_view
  use Tails
  require Ash.Query
  alias Gits.Storefront.Event

  def mount(params, _, socket) do
    user = socket.assigns.current_user

    customer =
      case user do
        user when is_struct(user) ->
          Ash.Changeset.for_create(Customer, :create, %{user_id: user.id}, actor: user)
          |> Ash.create!()

        nil ->
          nil
      end

    event =
      Ash.Query.for_read(Event, :masked, %{id: params["id"]}, actor: user)
      |> Ash.Query.load([:address, tickets: [:available_for_customer]])
      |> Ash.read_one!()

    unless event do
      raise GitsWeb.Exceptions.NotFound
    end

    socket =
      socket
      |> assign(:customer, customer)
      |> assign(:event, event)
      |> assign(:page_title, event.name)
      |> assign(:basket, nil)
      |> assign(:feature_image, Gits.Bucket.get_feature_image_path(event.account_id, event.id))

    reload(socket, true)
  end

  def handle_params(_, _, socket) do
    {:noreply, SEO.assign(socket, socket.assigns.event)}
  end

  def handle_event("clear_basket", _, socket) do
    if socket.assigns.basket != nil and socket.assigns.basket.state == :open do
      socket.assigns.basket
      |> Ash.Changeset.for_update(:abandon, %{}, actor: socket.assigns.current_user)
      |> Ash.update!()
    end

    socket
    |> assign(:basket, nil)
    |> reload()
  end

  def handle_event("settle_basket", _unsigned_params, socket) do
    customer = socket.assigns.customer
    disabled = is_nil(socket.assigns.customer) or customer.tickets_count == 0

    socket =
      unless not is_nil(socket.assigns.basket) or disabled do
        user = socket.assigns.current_user
        customer = socket.assigns.customer

        basket =
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

        basket
        |> Ash.Changeset.for_update(:settle_free, %{}, actor: user)
        |> Ash.update!()

        socket |> assign(:basket, basket |> Ash.reload!())
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    user = socket.assigns.current_user

    Ash.Query.for_read(TicketInstance, :read, %{}, actor: user)
    |> Ash.Query.filter(ticket.id == ^unsigned_params["id"])
    |> Ash.Query.filter(state == :reserved)
    |> Ash.Query.limit(1)
    |> Ash.read_one!()
    |> Ash.Changeset.for_update(:release, %{}, actor: user)
    |> Ash.update!()

    reload(socket)
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    user = socket.assigns.current_user

    if is_nil(user) do
      {:noreply,
       redirect(socket,
         to: ~p"/register?return_to=#{~p"/events/#{socket.assigns.event.masked_id}"}"
       )}
    else
      try_creating_ticket(user, socket.assigns.customer, unsigned_params["id"])
      reload(socket)
    end
  end

  defp try_creating_ticket(user, customer, ticket_id) do
    with {:ok, ticket} <- Ash.get(Ticket, ticket_id, actor: user),
         {:ok, ticket} <- Ash.load(ticket, :available_for_customer, actor: user) do
      if ticket.available_for_customer > 0 do
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
      end
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
      |> Ash.Query.load([:instance_count, :available_for_customer])
      |> Ash.read!()

    socket =
      socket
      |> assign(:customer, customer)
      |> assign(:tickets, tickets)

    if initial, do: {:ok, socket, temporary_assigns: [{SEO.key(), nil}]}, else: {:noreply, socket}
  end
end
