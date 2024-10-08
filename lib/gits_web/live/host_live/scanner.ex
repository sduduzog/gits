defmodule GitsWeb.HostLive.Scanner do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> ok(false)
  end

  def render(%{live_action: :scan} = assigns) do
    ~H"""
    <div
      data-camera={@camera}
      class="w-screen h-dvh flex items-center justify-center"
      id="qr-scanner"
      phx-hook="QrScanner"
    >
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="p-2 grid gap-4" id="camera-list" phx-hook="QrScannerCameraList">
      <h1 class="grow p-2 items-center truncate text-2xl font-semibold">
        Pick a camera
      </h1>
    </div>
    """
  end

  def handle_params(%{"camera" => camera}, _uri, socket) do
    socket
    |> assign(:camera, camera)
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket |> noreply()
  end

  def handle_event("camera_choice", %{"id" => id}, socket) do
    socket |> push_patch(to: ~p"/hosts/test/events/event_id/attendees/scanner/#{id}") |> noreply()
  end
end
