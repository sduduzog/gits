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

    if is_nil(basket) do
      raise GitsWeb.Exceptions.NotFound, "no basket"
    end

    tickets =
      Ticket
      |> Ash.Query.for_read(:read_for_shopping, %{event_id: event.id, basket_id: basket.id},
        actor: user
      )
      |> Ash.read!()

    socket =
      assign(socket, :event, event)
      |> assign(:customer, customer)
      |> assign(:basket, basket)
      |> assign(:tickets, tickets)

    {:ok, socket, layout: {GitsWeb.Layouts, :next}}
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
        ticket
        |> Ash.Changeset.for_update(:remove_instance, %{instance: instance}, actor: user)
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

    Enum.find(tickets, fn ticket -> ticket.id == unsigned_params["id"] end)
    |> Ash.Changeset.for_update(:add_instance, %{instance: %{customer: customer, basket: basket}},
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

  def handle_event("lock_basket", _unsigned_params, socket) do
    %{
      current_user: user,
      basket: basket,
      event: event
    } = socket.assigns

    basket
    |> Ash.Changeset.for_update(:lock_for_checkout, %{}, actor: user)
    |> Ash.update!()

    {:noreply,
     push_navigate(socket, to: ~p"/events/#{event.masked_id}/tickets/#{basket.id}/summary")}
  end
end
