defmodule GitsWeb.HostLive.Scanner do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> ok(false)
  end

  def render(%{live_action: :scan} = assigns) do
    ~H"""
    <div>
      <div data-camera={@camera} class="sticky top-0 w-screen" id="qr-scanner" phx-hook="QrScanner">
      </div>
      <div>
        <div class="p-2">
          <button
            phx-click={JS.navigate(~p"/hosts/test/events/event_id/attendees", replace: true)}
            class="inline-flex h-9 items-center rounded-lg border px-4 py-2"
          >
            <.icon name="hero-chevron-left-mini" />
            <span class="text-sm font-semibold">Back</span>
          </button>
        </div>
        <div class="text-3xl">
          Lorem ipsum dolor sit amet, consectetur adipisicing elit. Veniam, aut sed! Numquam dolorum incidunt aliquam blanditiis aspernatur consequatur itaque atque obcaecati amet? Vero accusamus reprehenderit ipsum? Molestiae sed cumque sequi?
        </div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="grid gap-4 p-2" id="camera-list" phx-hook="QrScannerCameraList">
      <h1 class="grow items-center truncate p-2 text-2xl font-semibold">
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
