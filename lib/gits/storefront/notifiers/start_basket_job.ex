defmodule Gits.Storefront.Notifiers.StartBasketJob do
  use Ash.Notifier
  require Logger

  alias Gits.Workers.Basket

  def notify(%Ash.Notifier.Notification{data: data}) do
    Basket.new(%{id: data.id}, schedule_in: 20 * 60)
    |> Oban.insert()
  end
end
