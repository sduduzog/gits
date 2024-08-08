defmodule Gits.Storefront.Notifiers.StartBasketJob do
  use Ash.Notifier
  require Logger

  alias Gits.Workers.ReclaimBasket

  def notify(%Ash.Notifier.Notification{data: data}) do

    Ecto.Multi.new()
    |> Oban.insert(
      :open_basket_job,
      ReclaimBasket.new(%{id: data.id, state: :open}, schedule_in: 20)
    )
    |> Oban.insert(
      :payment_started_basket_job,
      ReclaimBasket.new(%{id: data.id, state: :payment_started}, schedule_in: 30)
    )
    |> Gits.Repo.transaction()

    :ok
  end
end
