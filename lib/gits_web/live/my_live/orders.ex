defmodule GitsWeb.MyLive.Orders do
  require Ash.Query
  alias Gits.Storefront.Order
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    Order
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(state == :completed)
    |> Ash.Query.load(:event_name)
    |> Ash.read()
    |> case do
      {:ok, orders} ->
        socket
        |> assign(
          :orders,
          orders
          |> Enum.map(fn order ->
            %{
              id: order.id,
              no: order.number,
              date: order.created_at,
              event: order.event_name,
              event_id: order.event_id,
              amount: order.total
            }
          end)
        )
        |> ok()
    end
  end

  def handle_params(%{"order_id" => order_id}, _uri, socket) do
    socket
    |> assign(:order_id, order_id)
    |> noreply()
  end

  def handle_params(_, _uri, socket) do
    socket
    |> assign(:order_id, "")
    |> noreply()
  end
end
