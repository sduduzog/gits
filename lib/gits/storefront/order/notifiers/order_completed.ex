defmodule Gits.Storefront.Order.Notifiers.OrderCompleted do
  use Ash.Notifier
  alias Gits.Oban.Workers.SendOrderCompletedEmail

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{data: %{state: :completed} = order}) do
    %{id: order.id}
    |> SendOrderCompletedEmail.new()
    |> Oban.insert()
    |> case do
      {:ok, _} -> :ok
    end
  end

  def notify(_) do
  end
end
