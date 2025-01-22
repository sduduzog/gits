defmodule GitsWeb.HostLive.Events.List do
  import GitsWeb.HostComponents
  use GitsWeb, :live_component

  def update(assigns, socket) do
    socket
    |> assign(:current_user, assigns.current_user)
    |> assign(:host, assigns.host)
    |> assign(:events, assigns.events)
    |> assign(:form, %{})
    |> ok()
  end
end
