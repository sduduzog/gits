defmodule GitsWeb.EventLive.Tickets do
  use GitsWeb, :live_view

  require Ash.Query
  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Event
  alias Gits.Storefront.Ticket

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    event =
      Event
      |> Ash.Query.for_read(:for_feature, %{id: params["id"]}, actor: user)
      |> Ash.read_one!()

    customer =
      Customer
      |> Ash.Query.for_read(:read_for_shopping, %{}, actor: user)
      |> Ash.read_one!()

    basket =
      Basket
      |> Ash.Query.for_read(:read_for_shopping, %{id: params["basket_id"]}, actor: user)
      |> Ash.read_one!()

    socket =
      assign(socket, :event, event)
      |> assign(:customer, customer)
      |> assign(:basket, basket)

    {:ok, socket, layout: {GitsWeb.Layouts, :next}}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    user = socket.assigns.current_user
    event = socket.assigns.event
    basket = socket.assigns.basket

    tickets =
      Ticket
      |> Ash.Query.for_read(:read_for_shopping, %{event_id: event.id, basket_id: basket.id},
        actor: user
      )
      |> Ash.read!()

    socket = assign(socket, :tickets, tickets)

    {:noreply, socket}
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    %{
      tickets: tickets,
      current_user: user,
      event: event,
      basket: basket
    } = socket.assigns

    ticket =
      Enum.find(tickets, fn ticket -> ticket.id == unsigned_params["id"] end)

    basket.instances
    |> Enum.filter(fn x -> x.ticket_id == ticket.id end)
    |> Enum.sort(&(&1.id < &2.id))
    |> case do
      [instance | _] ->
        basket
        |> Ash.Changeset.for_update(
          :remove_ticket_from_basket,
          %{
            instance: instance.id
          },
          actor: user
        )
        |> Ash.update!()

      _ ->
        nil
    end

    basket =
      Basket
      |> Ash.Query.for_read(:read_for_shopping, %{id: basket.id}, actor: user)
      |> Ash.read_one!()

    tickets =
      Ticket
      |> Ash.Query.for_read(:read_for_shopping, %{event_id: event.id, basket_id: basket.id},
        actor: user
      )
      |> Ash.read!()

    socket =
      socket |> assign(:tickets, tickets) |> assign(:basket, basket)

    {:noreply, socket}
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    %{
      tickets: tickets,
      current_user: user,
      event: event,
      customer: customer,
      basket: basket
    } = socket.assigns

    ticket =
      Enum.find(tickets, fn ticket -> ticket.id == unsigned_params["id"] end)

    basket
    |> Ash.Changeset.for_update(
      :add_ticket_to_basket,
      %{
        instance: %{
          ticket: ticket,
          customer: customer
        }
      },
      actor: user
    )
    |> Ash.update!()

    basket =
      Basket
      |> Ash.Query.for_read(:read_for_shopping, %{id: basket.id}, actor: user)
      |> Ash.read_one!()

    tickets =
      Ticket
      |> Ash.Query.for_read(:read_for_shopping, %{event_id: event.id, basket_id: basket.id},
        actor: user
      )
      |> Ash.read!()

    socket = socket |> assign(:tickets, tickets) |> assign(:basket, basket)
    {:noreply, socket}
  end

  def handle_event("package_tickets", _unsigned_params, socket) do
    {:noreply,
     update(socket, :basket, fn current_basket, %{current_user: user} ->
       current_basket
       |> Ash.Changeset.for_update(:package_tickets, %{}, actor: user)
       |> Ash.update!()
     end)}
  end
end
