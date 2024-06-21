defmodule Gits.Storefront.Notifiers.StartBasketJob do
  use Ash.Notifier
  require Logger

  alias Gits.Workers.Basket

  def notify(%Ash.Notifier.Notification{data: data}) do
    Basket.new(%{id: data.id}, schedule_in: 30 * 60)
    |> Oban.insert()

    :ok
  end
end
