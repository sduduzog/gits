defmodule GitsWeb.ScanAttendeeLive do
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    socket =
      assign(socket, :cameras, [])
      |> assign(:camera_id, nil)
      |> assign(:scan_results, nil)
      |> assign(:account_id, params["account_id"])
      |> assign(:event_id, params["event_id"])

    {:ok, socket, layout: false}
  end

  def handle_params(unsigned_params, _uri, socket) do
    socket =
      socket
      |> assign(:scan_results, unsigned_params["code"])
      |> assign(:camera_id, unsigned_params["camera_id"])

    {:noreply, socket}
  end

  def handle_event("cameras", unsigned_params, socket) do
    socket = assign(socket, :cameras, unsigned_params)
    {:noreply, socket}
  end

  def handle_event("scanned", unsigned_params, socket) do
    url =
      "/accounts/#{socket.assigns.account_id}/events/#{socket.assigns.event_id}/attendees/new?code=#{unsigned_params}"

    {:noreply, push_navigate(socket, to: url)}
  end

  def handle_event(_, _unsigned_params, socket) do
    {:noreply, socket}
  end
end
