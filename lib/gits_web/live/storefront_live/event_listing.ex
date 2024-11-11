defmodule GitsWeb.StorefrontLive.EventListing do
  alias Gits.Storefront.{Event, Order}
  alias AshPhoenix.Form
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    Event.get_by_public_id_for_listing(params["public_id"])
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:form, Order |> Form.for_create(:create))
    end
    |> assign(:verified?, false)
    |> assign_new(:remote_ip, fn -> get_connect_info(socket, :peer_data).address end)
    |> ok()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket |> noreply()
  end

  def handle_event("turnstile:success", _, socket) do
    socket
    |> assign(:verified?, true)
    |> noreply()
  end

  def handle_event("get_tickets", unsigned_params, socket) do
    case Turnstile.verify(unsigned_params, socket.assigns.remote_ip) do
      {:ok, _} ->
        nil

      {:error, _} ->
        nil
    end

    socket |> noreply()
  end
end
