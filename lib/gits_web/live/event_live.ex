defmodule GitsWeb.EventLive do
  alias Gits.Storefront.TicketInstance
  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Ticket
  use GitsWeb, :live_view
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
      Ash.Query.for_read(Event, :masked, %{id: params["id"]}, actor: customer)
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

    {:ok, socket, temporary_assigns: [{SEO.key(), nil}]}
  end

  def handle_params(_, _, socket) do
    reload(SEO.assign(socket, socket.assigns.event))
  end

  def handle_event("clear_basket", _, socket) do
    {:noreply, socket}
  end

  def handle_event("settle_basket", _unsigned_params, socket) do
    customer = socket.assigns.customer

    event =
      socket.assigns.event

    amount = event.customer_reserved_instance_total

    instances =
      event.tickets
      |> Ash.load!([instances: TicketInstance |> Ash.Query.filter(state == :reserved)],
        actor: customer
      )
      |> Enum.flat_map(fn ticket -> ticket.instances end)

    socket =
      if amount == 0 do
        basket =
          Ash.Changeset.for_create(
            Basket,
            :create_settled,
            %{amount: amount, event: event, instances: instances},
            actor: customer
          )
          |> Ash.create!()

        assign(socket, :basket, basket)
      else
        socket
      end

    reload(socket)
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    customer = socket.assigns.customer

    ticket =
      Ash.Query.for_read(Ticket, :read, %{}, actor: customer)
      |> Ash.Query.filter(id: unsigned_params["id"])
      |> Ash.Query.load(
        instances: Ash.Query.filter(TicketInstance, state == :reserved) |> Ash.Query.limit(1)
      )
      |> Ash.read_one!()

    instance =
      ticket.instances
      |> hd()

    ticket
    |> Ash.Changeset.for_update(:remove_instance, %{instance: instance}, actor: customer)
    |> Ash.update()

    reload(socket)
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    user = socket.assigns.current_user
    customer = socket.assigns.customer
    ticket = Ash.get!(Ticket, unsigned_params["id"], actor: user)

    unless is_nil(customer) do
      ticket
      |> Ash.Changeset.for_update(:add_instance, %{instance: %{customer: customer}},
        actor: customer
      )
      |> Ash.update()
    end

    if is_nil(user) do
      {:noreply,
       redirect(socket,
         to: ~p"/register?return_to=#{~p"/events/#{socket.assigns.event.masked_id}"}"
       )}
    else
      reload(socket)
    end
  end

  defp reload(socket) do
    customer = socket.assigns.customer

    event =
      socket.assigns.event
      |> Ash.load!(
        [
          :address,
          :customer_reserved_instance_count,
          :customer_reserved_instance_total,
          tickets: [:customer_reserved_instance_count, :customer_reserved_instance_total]
        ],
        actor: customer
      )

    socket = assign(socket, :event, event)

    {:noreply, socket}
  end
end
