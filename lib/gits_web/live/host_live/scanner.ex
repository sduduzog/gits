defmodule GitsWeb.HostLive.Scanner do
  use GitsWeb, :host_live_view

  def mount(params, _session, socket) do
    socket
    |> assign(:host_handle, params["handle"])
    |> assign(:public_id, params["public_id"])
    |> ok(:host_panel)
  end

  def render(%{live_action: :scan} = assigns) do
    ~H"""
    <div>
      <div
        data-camera={@camera}
        class="sticky top-0 w-full max-w-md overflow-hidden rounded-xl"
        id="qr-scanner"
        phx-hook="QrScanner"
      >
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center">
      <div class="grow">
        <h2 class="text-lg/7 font-semibold text-gray-900">
          Scan code
        </h2>
        <p class="mb-4 mt-1 text-sm/5 text-gray-600"></p>
      </div>
    </div>

    <div class="grid gap-4" id="camera-list" phx-hook="QrScannerCameraList">
      <span>Choose camera to use</span>
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
    socket
    |> push_patch(
      to:
        Routes.host_scanner_path(
          socket,
          :scan,
          socket.assigns.host_handle,
          socket.assigns.public_id,
          id
        ),
      replace: true
    )
    |> noreply()
  end
end
