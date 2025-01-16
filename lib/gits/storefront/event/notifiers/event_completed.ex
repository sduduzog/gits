defmodule Gits.Storefront.Event.Notifiers.EventCompleted do
  require Decimal
  use Ash.Notifier
  require Ash.Query
  alias Gits.Storefront.Event
  use Oban.Worker, unique: [keys: [:id], timestamp: :scheduled_at, period: :infinity]

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{action: %{name: :publish}, data: event}) do
    schedule_time =
      DateTime.from_naive!(event.ends_at, "Africa/Johannesburg")
      |> DateTime.shift_zone!("Etc/UTC")

    %{id: event.id}
    |> __MODULE__.new(scheduled_at: schedule_time)
    |> Oban.insert()
    |> case do
      {:ok, _} ->
        :ok
    end
  end

  def notify(%Ash.Notifier.Notification{action: %{name: :details}, data: event}) do
    if event.state == :published do
      schedule_time =
        DateTime.from_naive!(event.ends_at, "Africa/Johannesburg")
        |> DateTime.shift_zone!("Etc/UTC")

      %{id: event.id}
      |> __MODULE__.new(
        scheduled_at: schedule_time,
        replace: [scheduled: [:max_attempts, :scheduled_at]]
      )
      |> Oban.insert()
      |> case do
        {:ok, _} ->
          :ok
      end
    end
  end

  def notify(_) do
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}} = job) do
    Ash.Query.filter(Event, id == ^id)
    |> Ash.Query.filter(state == :published)
    |> Ash.read_one()
    |> case do
      {:ok, nil} ->
        {:cancel, "Event not found"}

      {:ok, event} ->
        Ash.Changeset.for_update(event, :complete)
        |> Ash.update(actor: job)
    end
  end
end
