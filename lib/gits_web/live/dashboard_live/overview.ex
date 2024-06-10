defmodule GitsWeb.DashboardLive.Overview do
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Overview")
      |> assign(:context_options, nil)

    {:ok, socket, layout: {GitsWeb.Layouts, :catalyst}}
  end
end
