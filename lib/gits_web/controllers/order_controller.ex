defmodule GitsWeb.OrderController do
  require Ash.Query
  alias Gits.Storefront.Order
  alias Gits.PaystackApi
  use GitsWeb, :controller

  defp from_cents(amount) when is_integer(amount), do: Decimal.new(amount) |> from_cents()
  defp from_cents(amount) when is_float(amount), do: Decimal.from_float(amount) |> from_cents()
  defp from_cents(amount), do: Decimal.div(amount, 100)

  def paystack_callback(conn, params) do
    PaystackApi.verify_transaction(params["reference"])
    |> case do
      {:ok, %{status: :success}, %{"fees_split" => fees_split, "reference" => reference}} ->
        Ash.Query.filter(Order, paystack_reference == ^reference)
        |> Ash.Query.load(:event)
        |> Ash.read_one()
        |> case do
          {:ok, nil} ->
            nil

          {:ok, order} ->
            Ash.Changeset.for_update(order, :complete, %{
              fees_split: %{
                integration: fees_split["integration"] |> from_cents(),
                paystack: fees_split["paystack"] |> from_cents(),
                subaccount: fees_split["subaccount"] |> from_cents()
              }
            })
            |> Ash.update()

            conn
            |> redirect(
              to:
                Routes.storefront_event_order_path(conn, :index, order.event.public_id, order.id)
            )
        end
    end

    text(conn, "query by reference")
  end
end
