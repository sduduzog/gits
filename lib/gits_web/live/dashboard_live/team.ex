defmodule GitsWeb.DashboardLive.Team do
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    socket = socket |> assign(:slug, params["slug"]) |> assign(:title, "Team")
    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next}}
  end
end
