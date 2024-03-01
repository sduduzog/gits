defmodule GitsWeb.HomeLive.Index do
  use GitsWeb, :live_view

  def render(assigns) do
    ~H"""
    <.live_component module={GitsWeb.HomeLive.Header} id="1" current_user={@current_user} />
    <div class="h-96"></div>
    """
  end

  def mount(_params, _session, socket) do
    signed_in = socket.assigns.current_user != nil
    {:ok, assign(socket, :signed_in, signed_in)}
  end
end
