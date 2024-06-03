defmodule GitsWeb.DashboardLive.EventDetails do
  use GitsWeb, :live_view

  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Events")

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next}}
  end

  def handle_params(unsigned_params, _uri, socket) do
    user = socket.assigns.current_user

    event =
      Event
      |> Ash.Query.for_read(:for_dashboard_event_details, %{id: unsigned_params["event_id"]},
        actor: user
      )
      |> Ash.read_one!()
      |> IO.inspect()

    socket = assign(socket, :event, event)

    {:noreply, socket}
  end
end
