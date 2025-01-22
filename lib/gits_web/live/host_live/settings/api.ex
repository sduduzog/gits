defmodule GitsWeb.HostLive.Settings.Api do
  use GitsWeb, :live_component

  import GitsWeb.HostComponents

  def update(assigns, socket) do
    socket
    |> assign(:current_user, assigns.current_user)
    |> assign(:host, assigns.host)
    |> assign(:form, %{})
    |> ok()
  end
end
