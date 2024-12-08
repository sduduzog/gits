defmodule GitsWeb.HostLive.Scanner do
  require Ash.Query
  alias Phoenix.LiveView.AsyncResult
  alias Gits.Storefront.Ticket
  use GitsWeb, :host_live_view

  def mount(params, _session, socket) do
    socket
    |> assign(:host_handle, params["handle"])
    |> assign(:public_id, params["public_id"])
    |> ok(:host_panel)
  end

  def handle_params(%{"camera" => camera} = unsigned_params, _uri, socket) do
    socket
    |> assign(:camera, camera)
    |> assign_results(unsigned_params, socket.assigns.current_user)
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

  def handle_event("scanned", unsigned_params, socket) do
    case socket.assigns.ticket.loading do
      [:ticket] ->
        socket
        |> push_patch(
          to:
            Routes.host_scanner_path(
              socket,
              :scan,
              socket.assigns.host_handle,
              socket.assigns.public_id,
              socket.assigns.camera,
              unsigned_params
            ),
          replace: true
        )
        |> noreply()

      nil ->
        noreply(socket)
    end
  end

  def handle_event("check_in", _unsigned_params, socket) do
    assign(socket, :test, true)
    |> noreply()
  end

  defp assign_results(socket, %{"text" => text}, actor) do
    String.slice(text, -9, 9)
    |> case do
      "/t/" <> code ->
        assign(socket, :show_modal, true)
        |> assign_async(
          :ticket,
          fn ->
            Ash.Query.filter(Ticket, public_id == ^code)
            |> Ash.Query.load(ticket_type: [:event])
            |> Ash.read_one(actor: actor)
            |> case do
              {:ok, ticket} ->
                {:ok, %{ticket: ticket}}

              _ ->
                {:error, :reason}
            end
          end,
          reset: true
        )
    end
  end

  defp assign_results(socket, _, _) do
    assign(socket, :show_modal, false)
    |> assign(:ticket, AsyncResult.loading([:ticket]))
  end

  def render(%{live_action: :scan} = assigns) do
    ~H"""
    <div>
      <div
        data-camera={@camera}
        data-callback={show_modal("scan_result")}
        class="sticky top-0 w-full max-w-md overflow-hidden rounded-xl"
        id="qr-scanner"
        phx-update="ignore"
        phx-hook="QrScanner"
      >
      </div>
    </div>

    <.modal
      on_cancel={
        JS.patch(
          Routes.host_scanner_path(
            @socket,
            :scan,
            @host_handle,
            @public_id,
            @camera
          ),
          replace: true
        )
      }
      id="scan_result"
      show={@show_modal}
    >
      <div class="grid gap-8">
        <%= if @ticket.ok? do %>
          <div class="flex gap-2">
            <div class="flex grow items-center gap-3">
              <.icon name="i-lucide-circle-check" class=" text-green-500" />
              <div class="flex items-center grow gap-6">
                <p class="text-sm">Ticket validated</p>
                <span
                  :if={@ticket.result.admitted_at}
                  class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20"
                >
                  Admitted
                </span>
              </div>
            </div>
          </div>

          <div class="flex items-center gap-4">
            <span
              class="w-1.5 self-stretch rounded-full"
              style={"background-color: #{@ticket.result.ticket_type.color}"}
            >
            </span>
            <div class="grow">
              <span class="text-sm/4 font-medium">{@ticket.result.ticket_type.name}</span>
              <div class="flex gap-2 text-sm/4 text-zinc-500">
                <%= if true do %>
                  <span>Available</span>
                <% else %>
                  <span>Available</span>
                <% end %>
              </div>
            </div>
          </div>
          <div :if={false} class="flex items-center gap-2">
            <.button variant={:outline} class="shrink-0">
              <.icon name="i-lucide-user-round-check" />
              <!-- <span>Check in</span> -->
            </.button>
          </div>
        <% else %>
          <div class="flex gap-2">
            <div :if={@ticket.loading == [:ticket]} class="flex grow items-center gap-3">
              <.icon name="i-lucide-loader-circle" class="text-zinc-600 animate-spin" />
              <div class="flex items-center grow gap-6">
                <p class="text-sm">Loading...</p>
              </div>
            </div>
            <div :if={@ticket.failed} class="flex grow items-center gap-3">
              <.icon name="i-lucide-circle-x" class="text-red-500" />
              <div class="flex items-center grow gap-6">
                <p class="text-sm">{error_to_string(@ticket.failed)}</p>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </.modal>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="grid gap-4" id="camera-list" phx-hook="QrScannerCameraList">
      <span>Choose camera to use</span>
    </div>
    """
  end

  defp error_to_string({:error, :reason}), do: "Failed because..."
end
