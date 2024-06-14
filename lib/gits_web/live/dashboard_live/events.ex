defmodule GitsWeb.DashboardLive.Events do
  use GitsWeb, :live_view

  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Events")
      |> assign(:context_options, nil)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_params(unsigned_params, _uri, socket) do
    user = socket.assigns.current_user

    events =
      Event
      |> Ash.Query.for_read(:read_dashboard_events, %{account_id: unsigned_params["slug"]},
        actor: user
      )
      |> Ash.read!()

    socket = assign(socket, :events, events)

    {:noreply, socket}
  end
end
