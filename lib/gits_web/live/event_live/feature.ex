defmodule GitsWeb.EventLive.Feature do
  use GitsWeb, :live_view

  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    event =
      Ash.Query.for_read(Event, :for_feature, %{id: params["id"]}, actor: user)
      |> Ash.read_one!()

    {:ok, assign(socket, :event, event), layout: {GitsWeb.Layouts, :next}}
  end

  def handle_event("get_tickets", _unsigned_params, socket) do
    user =
      socket.assigns.current_user

    event = socket.assigns.event

    socket =
      if is_nil(user) do
        redirect(socket,
          to: ~p"/sign-in" <> "?return_to=" <> ~p"/events/#{event.masked_id}/tickets"
        )
      else
        socket |> open_basket()
      end

    {:noreply, socket}
  end

  defp open_basket(socket) do
    user =
      socket.assigns.current_user

    event = socket.assigns.event

    customer =
      Customer
      |> Ash.Changeset.for_create(:create, %{user: user}, actor: user)
      |> Ash.create!()
      |> IO.inspect()

    basket =
      Basket
      |> Ash.Changeset.for_create(:open_basket, %{event: event, customer: customer}, actor: user)
      |> Ash.create!()

    redirect(socket, to: ~p"/events/#{event.masked_id}/tickets/#{basket.id}")
  end
end
