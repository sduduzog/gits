defmodule GitsWeb.EventLive.Feature do
  use GitsWeb, :live_view

  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    event =
      Ash.Query.for_read(Event, :for_feature, %{id: params["id"]}, actor: user)
      |> Ash.read_one!()

    {:ok, assign(socket, :event, event), layout: {GitsWeb.Layouts, :next}}
  end

  def handle_event("get_tickets", _unsigned_params, socket) do
    {:noreply, socket}
  end
end
