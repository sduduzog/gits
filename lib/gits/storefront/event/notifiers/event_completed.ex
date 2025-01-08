defmodule Gits.Storefront.Event.Notifiers.EventCompleted do
  require Decimal
  use Ash.Notifier
  require Ash.Query
  alias Gits.Storefront.Event
  use Oban.Worker, unique: [keys: [:id], timestamp: :scheduled_at, period: :infinity]

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{data: event}) do
    %{id: event.id}
    |> __MODULE__.new()
    |> Oban.insert()
    |> case do
      {:ok, _} ->
        :ok
    end
  end

  def notify(_) do
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}} = job) do
    Ash.Query.filter(Event, id == ^id)
    |> Ash.read_one()
    |> case do
      {:ok, nil} ->
        :discard

      {:ok, event} ->
        # report completed event
        :ok
    end
  end
end
