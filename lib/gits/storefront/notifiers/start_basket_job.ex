defmodule Gits.Storefront.Notifiers.StartBasketJob do
  use Ash.Notifier
  require Logger

  alias Gits.Workers.ReclaimBasket

  def notify(%Ash.Notifier.Notification{data: data}) do
    [reclaim_open_basket_timeout, reclaim_payment_started_basket_timeout] =
      Application.get_env(:gits, :workers)

    Ecto.Multi.new()
    |> Oban.insert(
      :open_basket_job,
      ReclaimBasket.new(%{id: data.id, state: :open}, schedule_in: reclaim_open_basket_timeout)
    )
    |> Oban.insert(
      :payment_started_basket_job,
      ReclaimBasket.new(%{id: data.id, state: :payment_started}, schedule_in: reclaim_payment_started_basket_timeout)
    )
    |> Gits.Repo.transaction()

    :ok
  end
end
