defmodule GitsWeb.HostLive.Events.List do
  import GitsWeb.HostComponents
  use GitsWeb, :live_component

  def update(assigns, socket) do
    socket
    |> assign(:current_user, assigns.current_user)
    |> assign(:handle, assigns.handle)
    |> assign(:host_name, assigns.host_name)
    |> assign(:events, assigns.events)
    |> ok()
  end
end
