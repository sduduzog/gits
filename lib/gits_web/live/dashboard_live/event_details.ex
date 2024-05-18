defmodule GitsWeb.DashboardLive.EventDetails do
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Events")

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next}}
  end
end
