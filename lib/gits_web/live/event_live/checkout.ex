defmodule GitsWeb.EventLive.Checkout do
  use GitsWeb, :live_view

  require Ash.Query
  alias Gits.Storefront.Basket
  alias Gits.Storefront.Event
  alias Gits.Storefront.Ticket

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    event =
      Event
      |> Ash.Query.for_read(:for_feature, %{id: params["id"]}, actor: user)
      |> Ash.read_one!()

    basket =
      Basket
      |> Ash.Query.for_read(:read_for_checkout, %{id: params["basket_id"]}, actor: user)
      |> Ash.read_one!()

    tickets =
      Ticket
      |> Ash.Query.for_read(
        :read_for_checkout_summary,
        %{event_id: event.id, basket_id: basket.id},
        actor: user
      )
      |> Ash.read!()

    if is_nil(basket) do
      raise GitsWeb.Exceptions.NotFound, "no basket"
    end

    socket =
      assign(socket, :event, event)
      |> assign(:basket, basket)
      |> assign(:tickets, tickets)

    GitsWeb.Endpoint.subscribe("basket:cancelled:#{basket.id}")

    {:ok, socket, layout: {GitsWeb.Layouts, :next}}
  end

  def handle_event("continue_shopping", _unsigned_params, socket) do
    %{
      current_user: user,
      basket: basket,
      event: event
    } = socket.assigns

    basket
    |> Ash.Changeset.for_update(:unlock_for_shopping, %{}, actor: user)
    |> IO.inspect()
    |> Ash.update!()

    {:noreply, push_navigate(socket, to: ~p"/events/#{event.masked_id}/tickets/#{basket.id}")}
  end

  def handle_event("checkout", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_info(_msg, socket) do
    event = socket.assigns.event

    {:noreply, push_navigate(socket, to: ~p"/events/#{event.masked_id}")}
  end
end
