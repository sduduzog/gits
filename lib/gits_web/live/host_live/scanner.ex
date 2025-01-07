defmodule GitsWeb.HostLive.Scanner do
  require Ash.Query
  alias Phoenix.LiveView.AsyncResult
  alias Gits.Storefront.Ticket
  use GitsWeb, :host_live_view

  def mount(params, _session, socket) do
    socket
    |> assign(:host_handle, params["handle"])
    |> assign(:public_id, params["public_id"])
    |> assign(:test, false)
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

  def handle_event("admit", _unsigned_params, socket) do
    ticket = socket.assigns.ticket.result
    user = socket.assigns.current_user

    socket
    |> assign_async(
      :ticket,
      fn ->
        Ash.Changeset.for_update(ticket, :admit)
        |> Ash.update(
          actor: user,
          load: [:local_admitted_at, :attendee, ticket_type: [:event]]
        )
        |> case do
          {:ok, ticket} ->
            {:ok, %{ticket: ticket}}

          _ ->
            {:error, :reason}
        end
      end,
      reset: true
    )
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
            |> Ash.Query.load([:local_admitted_at, :attendee, ticket_type: [:event]])
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
          <GitsWeb.EventComponents.ticket_card
            name={@ticket.result.ticket_type.name}
            color={@ticket.result.ticket_type.color}
            id={@ticket.result.public_id}
            tags={[
              @ticket.result.public_id,
              if(@ticket.result.state == :admitted,
                do:
                  "Admitted at #{Calendar.strftime(@ticket.result.local_admitted_at, "%I:%M:%S %p, %A")}",
                else: @ticket.result.state
              )
            ]}
          />

          <div :if={@ticket.result.attendee} class="flex gap-4 items-end">
            <div class="size-28 rounded-xl bg-zinc-100"></div>
            <dl class="grid gap-2 text-sm/7">
              <div>
                <dt class="text-zinc-500">Name</dt>
                <dd class="font-medium text-base/4">Nkero</dd>
              </div>

              <div>
                <dt class="text-zinc-500">Checked in?</dt>
                <dd class="font-medium text-base/4">12:30 PM, 31 Jan 2024</dd>
              </div>
            </dl>
          </div>

          <div class="flex gap-2 h-10">
            <div class="flex grow items-center gap-3">
              <.icon name="i-lucide-circle-check" class=" text-green-500" />
              <div class="flex grow items-center gap-6">
                <p class="grow text-sm">Ticket validated</p>
                <.button :if={is_nil(@ticket.result.admitted_at)} phx-click="admit" size={:sm}>
                  <.icon name="i-lucide-user-round-check" />
                  <span>Admit</span>
                </.button>
              </div>
            </div>
          </div>
        <% else %>
          <div class="flex gap-2 h-10">
            <div :if={@ticket.loading == [:ticket]} class="flex grow items-center gap-3">
              <.icon name="i-lucide-loader-circle" class="animate-spin text-zinc-600" />
              <div class="flex grow items-center gap-6">
                <p class="text-sm">Loading...</p>
              </div>
            </div>
            <div :if={@ticket.failed} class="flex grow items-center gap-3">
              <.icon name="i-lucide-circle-x" class="text-red-500" />
              <div class="flex grow items-center gap-6">
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
