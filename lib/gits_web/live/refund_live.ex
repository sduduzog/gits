defmodule GitsWeb.RefundLive do
  require Ash.Query
  alias AshPhoenix.Form
  alias Gits.Storefront.Order
  use GitsWeb, :live_view

  def mount(%{"order" => order_id}, _, socket) do
    Ash.Query.for_read(Order, :read, %{}, load: [:refund_value])
    |> Ash.Query.filter(id: order_id)
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign(:form, Form.for_update(order, :refund))
        |> ok(:host_panel)
    end
  end

  def mount(_params, _, socket) do
    ok(socket, :not_found)
  end

  def handle_event("refund_requested", _, socket) do
    Ash.Changeset.for_update(socket.assigns.order, :request_refund)
    |> Ash.update(actor: socket.assigns.current_user)
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign(:form, Form.for_update(order, :refund))
    end

    socket |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> noreply()
    end
  end
end
