defmodule Gits.Storefront.Order.Notifiers.OrderRefunded do
  require Decimal
  use Ash.Notifier
  alias Gits.PaystackApi
  alias Gits.Storefront.Order
  use Oban.Worker

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{data: %Order{state: :refunded} = order}) do
    %{id: order.id}
    |> __MODULE__.new()
    |> Oban.insert()
    |> case do
      {:ok, _} -> :ok
    end
  end

  def notify(_) do
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}} = job) do
    Ash.get(Order, id, load: [:fees_split], actor: job)
    |> case do
      {:ok, order} ->
        PaystackApi.create_refund(
          order.paystack_reference,
          Decimal.mult(order.fees_split.subaccount, 100)
        )

      {:error, error} ->
        {:error, error}
    end
  end
end
