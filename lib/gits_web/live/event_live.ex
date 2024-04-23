defmodule GitsWeb.EventLive do
  alias Gits.Storefront.TicketInstance
  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
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
      |> assign(:tickets, [])
      |> assign(:summary_line, nil)
      |> assign(:hint, nil)

    {:ok, socket, temporary_assigns: [{SEO.key(), nil}]}
  end

  def handle_params(_, _, socket) do
    reload(SEO.assign(socket, socket.assigns.event))
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
    customer = socket.assigns.customer

    event =
      socket.assigns.event

    ticket =
      Enum.find(event.tickets, fn %Ticket{id: id} -> id == unsigned_params["id"] end)
      |> Ash.load!(
        [instances: Ash.Query.filter(TicketInstance, state == :reserved) |> Ash.Query.limit(1)],
        actor: customer
      )

    [instance] = ticket.instances

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
          tickets: [:customer_reserved_instance_count]
        ],
        actor: customer
      )

    socket = assign(socket, :event, event)

    {:noreply, socket}
  end
end
