defmodule Gits.Storefront.Order.Notifiers.OrderCreated do
  use Ash.Notifier
  require Ash.Query
  alias Gits.PaystackApi
  alias Gits.Storefront.Order
  use Oban.Worker

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{data: order}) do
    schedule_time =
      Application.get_env(:gits, :workers)
      |> Keyword.get(:order_created_schedule_seconds)

    %{id: order.id}
    |> __MODULE__.new(schedule_in: schedule_time)
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
    |> Ash.Query.filter(state in [:anonymous, :open, :processed, :confirmed])
    |> Ash.read_one(actor: job)
    |> case do
      {:ok, nil} ->
        {:cancel, "No matching order found"}

      {:ok, %{state: :confirmed} = order} ->
        PaystackApi.get_transaction_status(order.paystack_reference)
        |> case do
          {:ok, :ongoing} ->
            if job.attempt > 3 do
              Ash.Changeset.for_update(order, :cancel, %{
                reason: "Order timeout. Payment took too long"
              })
              |> Ash.update(actor: job)
            else
              snooze_time =
                Application.get_env(:gits, :workers)
                |> Keyword.get(:order_created_snooze_seconds)

              {:snooze, snooze_time * job.attempt}
            end
        end

      {:error, error} ->
        {:error, error}
    end
  end
end
