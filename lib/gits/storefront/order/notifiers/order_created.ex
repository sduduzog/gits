defmodule Gits.Storefront.Order.Notifiers.OrderCreated do
  use Ash.Notifier
  require Ash.Query
  alias Gits.Storefront.Order
  use Oban.Worker, unique: [keys: [:id, :task], timestamp: :scheduled_at, period: :infinity]

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{action: %{name: :create}, data: order}) do
    %{id: order.id}
    # |> __MODULE__.new(schedule_in: 1_200)
    |> __MODULE__.new(schedule_in: 30)
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
        :discard

      {:ok, order} ->
        Ash.Changeset.for_update(order, :cancel)
        |> Ash.update(actor: job)
        |> IO.inspect()

      {:error, error} ->
        {:error, error}
    end
  end
end
