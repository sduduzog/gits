defmodule GitsWeb.DashboardLive.Settings do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    socket = socket |> assign(:nav, []) |> assign(:title, "Settings")
    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next}}
  end
end
