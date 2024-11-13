defmodule GitsWeb.HostLive.Settings do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Settings")
    |> ok()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket |> noreply()
  end
end
