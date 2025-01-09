defmodule Gits.Storefront.Order.Notifiers.OrderCancelled do
  use Ash.Notifier
  require Ash.Query
  alias Gits.PaystackApi
  alias Gits.Storefront.Order
  use Oban.Worker

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{data: order}) do
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
    Ash.Query.filter(Order, id == ^id)
    |> Ash.Query.filter(state in [:cancelled])
    |> Ash.read_one(actor: job)
    |> case do
      {:ok, nil} ->
        :discard

      {:ok, %{paystack_reference: nil}} ->
        :discard

      {:ok, order} ->
        PaystackApi.get_transaction_status(order.paystack_reference)
        |> case do
          {:ok, :ongoing} ->
            {:cancel, "Cancelling, transaction is ongoing"}

          {:ok, :abandoned} ->
            {:cancel, "Cancelling, transaction is abandoned"}

          {:ok, :success} ->
            PaystackApi.create_full_refund(
              order.paystack_reference,
              order.cancellation_reason
            )
        end

      {:error, error} ->
        {:error, error}
    end
  end
end
