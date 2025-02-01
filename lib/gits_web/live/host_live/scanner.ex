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
    |> ok(:wizard)
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

  def handle_event("close", _, socket) do
    socket
    |> push_navigate(
      to:
        Routes.host_events_path(
          socket,
          :admissions,
          socket.assigns.host_handle,
          socket.assigns.public_id
        ),
      replace: true
    )
    |> noreply()
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
      [] ->
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
    String.slice(text, -13, 13)
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
              {:ok, nil} ->
                {:error, :not_found}

              {:ok, ticket} ->
                {:ok, %{ticket: ticket}}

              _ ->
                {:error, :unknown}
            end
          end,
          reset: true
        )
    end
  end

  defp assign_results(socket, _, _) do
    assign(socket, :show_modal, false)
    |> assign(:ticket, AsyncResult.loading([]))
    |> assign(:invite, AsyncResult.loading([]))
  end

  defp error_to_string({:error, :unknown}), do: "Failed to fetch ticket"
  defp error_to_string({:error, :not_found}), do: "Invalid ticket"
end
