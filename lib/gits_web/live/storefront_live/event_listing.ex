defmodule GitsWeb.StorefrontLive.EventListing do
  alias Gits.Storefront.{Event, Order}
  alias AshPhoenix.Form
  use GitsWeb, :live_view

  def mount(%{"public_id" => public_id}, _session, socket) do
    Event.get_by_public_id_for_listing(public_id)
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:verified?, false)
        |> assign_new(:remote_ip, fn -> get_connect_info(socket, :peer_data).address end)
        |> assign(:form, Order |> Form.for_create(:create))
        |> ok()

      {:error, _} ->
        socket
        |> assign(:page_title, "Not found")
        |> ok(:not_found)
    end
  end

  def handle_params(%{"order_id" => _}, _uri, socket) do
    socket
    |> noreply()
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
    with :ok <- verify_turnstile(unsigned_params, socket.assigns.remote_ip),
         {:ok, order_id} <- create_order(socket.assigns.form, unsigned_params) do
      socket
      |> redirect(
        to:
          Routes.storefront_event_listing_path(
            socket,
            :order,
            socket.assigns.event.public_id,
            order_id
          )
      )
      |> noreply()
    end
  end

  defp verify_turnstile(params, remote_ip) do
    params |> IO.inspect()

    case Turnstile.verify(params, remote_ip) do
      {:ok, _} ->
        :ok

      {:error, _} ->
        :error
    end
  end

  defp create_order(form, params) do
    form
    |> Form.submit(params: params)
    |> case do
      {:ok, order} -> {:ok, order.id}
    end
  end
end
