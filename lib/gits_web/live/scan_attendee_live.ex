defmodule GitsWeb.ScanAttendeeLive do
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    socket =
      assign(socket, :cameras, [])
      |> assign(:scan_results, nil)
      |> assign(:account_id, params["account_id"])
      |> assign(:event_id, params["event_id"])

    {:ok, socket}
  end

  def handle_params(unsigned_params, _uri, socket) do
    IO.inspect(unsigned_params)
    {:noreply, assign(socket, :scan_results, unsigned_params["code"])}
  end

  def handle_event("cameras", unsigned_params, socket) do
    socket = assign(socket, :cameras, unsigned_params)
    {:noreply, socket}
  end

  def handle_event("change_camera", unsigned_params, socket) do
    {:noreply, push_event(socket, "change_camera", %{id: unsigned_params["id"]})}
  end

  def handle_event("scanned", unsigned_params, socket) do
    url =
      ~p"/accounts/#{socket.assigns.account_id}/events/#{socket.assigns.event_id}/attendees/new?code=#{unsigned_params}"

    {:noreply, push_navigate(socket, to: url)}
  end

  def handle_event(_, _unsigned_params, socket) do
    {:noreply, socket}
  end
end
