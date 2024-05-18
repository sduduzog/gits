defmodule GitsWeb.DashboardLive.Settings do
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    socket = socket |> assign(:slug, params["slug"]) |> assign(:title, "Settings")
    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next}}
  end
end
