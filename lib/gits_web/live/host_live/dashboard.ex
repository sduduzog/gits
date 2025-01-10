defmodule GitsWeb.HostLive.Dashboard do
  use GitsWeb, :live_view

  require Ash.Query

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Dashboard")
    |> ok(:host)
  end

  def render(assigns) do
    ~H"""
    <h1 class="p-2 text-xl font-semibold">Hello {@current_user.name}</h1>
    """
  end
end
