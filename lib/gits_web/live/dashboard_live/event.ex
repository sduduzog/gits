defmodule GitsWeb.DashboardLive.Event do
  use GitsWeb, :live_view

  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    event =
      Event
      |> Ash.Query.for_read(:read_dashboard_event, %{id: params["event_id"]}, actor: user)
      |> Ash.read_one!()

    socket = assign(socket, :event, event)

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, event.name)
      |> assign(:context_options, [%{label: "Tickets"}])

    {:ok, socket, layout: {GitsWeb.Layouts, :catalyst}}
  end
end
