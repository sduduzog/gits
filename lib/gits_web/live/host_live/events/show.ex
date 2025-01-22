defmodule GitsWeb.HostLive.Events.Show do
  import GitsWeb.HostComponents
  use GitsWeb, :live_component

  def update(assigns, socket) do
    socket
    |> assign(:current_user, assigns.current_user)
    |> assign(:host, assigns.host)
    |> assign(:event, assigns.event)
    |> assign(:action, assigns.live_action)
    |> ok()
  end
end
