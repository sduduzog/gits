defmodule GitsWeb.StorefrontLive.EventListing do
  require Ash.Query
  alias Gits.Storefront.Order
  alias Gits.Accounts.User
  alias Gits.Storefront.{Event}
  alias AshPhoenix.Form
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    remote_ip = get_connect_info(socket, :peer_data).address

    Event.get_by_public_id_for_listing(params["public_id"], load: :ticket_types)
    |> case do
      {:ok, event} ->
        socket
        |> assign(:verified?, not is_nil(socket.assigns.current_user))
        |> assign(:remote_ip, remote_ip)
        |> assign(:event, event)
        |> ok()

      {:error, _} ->
        socket
        |> assign(:page_title, "Not found")
        |> ok(:not_found)
    end
  end

  def handle_params(%{"order_id" => order_id}, _uri, socket) do
    Order
    |> Ash.get(order_id)
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign(:form, order_form(order))
        |> noreply()
    end
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket
    |> assign(
      :form,
      socket.assigns.event
      |> Form.for_update(:create_order, forms: [auto?: true])
      |> Form.add_form([:order])
    )
    |> assign(:order, nil)
    |> noreply()
  end

  def handle_event("turnstile:success", _, socket) do
    socket
    |> assign(:verified?, true)
    |> noreply()
  end

  def handle_event(
        "submit",
        %{"cf-turnstile-response" => _} = unsigned_params,
        %{assigns: %{live_action: :index}} = socket
      ) do
    socket.assigns |> IO.inspect()

    with :ok <-
           verify_turnstile(
             unsigned_params,
             socket.assigns.remote_ip,
             socket.assigns.current_user
           ),
         {:ok, order_id} <-
           create_order(socket.assigns.form, unsigned_params["form"], socket.assigns.event) do
      socket
      |> push_navigate(
        to:
          Routes.storefront_event_order_path(
            socket,
            :index,
            socket.assigns.event.public_id,
            order_id
          )
      )
      |> noreply()
    end
  end

  # def handle_event("submit", %{"cf-turnstile-response" => _} = unsigned_params, socket) do
  #
  #   with :ok <-
  #          verify_turnstile(
  #            unsigned_params,
  #            socket.assigns.remote_ip,
  #            socket.assigns.current_user
  #          ),
  #        {:ok, order_id} <-
  #          create_order(socket.assigns.form, unsigned_params["form"], socket.assigns.event) do
  #     socket
  #     |> push_patch(
  #       to:
  #         Routes.storefront_event_listing_path(
  #           socket,
  #           :order,
  #           socket.assigns.event.public_id,
  #           order_id
  #         )
  #     )
  #     |> noreply()
  #   end
  # end
  #
  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(
      :form,
      socket.assigns.form
      |> Form.validate(unsigned_params["form"])
    )
    |> noreply()
  end

  # def handle_event("submit", unsigned_params, socket) do
  #   socket |> noreply()
  # end

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

  defp order_form(order) do
    order
    |> Form.for_update(:process, forms: [auto?: true])
  end

  # defp current_form(%Event{} = event) do
  #   event
  #   |> Form.for_update(:create_order, forms: [auto?: true])
  #   |> Form.add_form([:order])
  # end

  def ticket_types() do
    nil
  end
end
