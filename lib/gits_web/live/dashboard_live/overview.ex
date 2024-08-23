defmodule GitsWeb.DashboardLive.Overview do
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    socket
    |> assign(:slug, params["slug"])
    |> assign(:current_route, :Overview)
    |> ok(:dashboard)
  end

  def render(assigns) do
    ~H"""
    <div>Home</div>
    """
  end
end
