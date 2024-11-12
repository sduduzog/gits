defmodule GitsWeb.StorefrontLive.EventListing do
  alias Gits.Accounts.User
  alias Gits.Storefront.{Event}
  alias AshPhoenix.Form
  use GitsWeb, :live_view

  def mount(%{"public_id" => public_id}, _session, socket) do
    remote_ip = get_connect_info(socket, :peer_data).address

    Event.get_by_public_id_for_listing(public_id)
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:verified?, not is_nil(socket.assigns.current_user))
        |> assign(:remote_ip, remote_ip)
        |> assign(
          :form,
          event
          |> Form.for_update(:add_order, forms: [auto?: true])
          |> Form.add_form([:order])
        )
        |> ok()

      {:error, _} ->
        socket
        |> assign(:page_title, "Not found")
        |> ok(:not_found)
    end
  end

  def handle_params(%{"order_id" => order_id}, _uri, socket) do
    socket
    |> assign(:order_id, order_id)
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket
    |> assign(:order_id, "")
    |> noreply()
  end

  def handle_event("turnstile:success", _, socket) do
    socket
    |> assign(:verified?, true)
    |> noreply()
  end

  def handle_event("get_tickets", unsigned_params, socket) do
    with :ok <-
           verify_turnstile(
             unsigned_params,
             socket.assigns.remote_ip,
             socket.assigns.current_user
           ),
         {:ok, order_id} <-
           create_order(socket.assigns.form, unsigned_params["form"], socket.assigns.event) do
      order_id |> IO.inspect()

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

  defp verify_turnstile(params, remote_ip, nil) do
    case Turnstile.verify(params, remote_ip) do
      {:ok, _} ->
        :ok

      {:error, _} ->
        :error
    end
  end

  defp verify_turnstile(_, _, %User{}), do: :ok

  defp create_order(form, params, event) do
    form
    |> Form.submit(params: Map.put(params, :event, event))
    |> case do
      {:ok, %{orders: [order]}} ->
        {:ok, order.id}
    end
  end
end
