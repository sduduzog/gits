defmodule Gits.Storefront.Notifiers.StartBasketJob do
  use Ash.Notifier
  require Logger

  alias Gits.Workers.ReclaimBasket

  def notify(%Ash.Notifier.Notification{data: data}) do
    # ReclaimBasket.new(%{id: data.id}, schedule_in: 2)
    # |> Oban.insert()
    #

    Ecto.Multi.new()
    |> Oban.insert(:open_basket_job, ReclaimBasket.new(%{id: data.id, state: :open}, schedule_in: 2))
    |> Oban.insert(:payment_started_basket_job, ReclaimBasket.new(%{id: data.id, state: :payment_started}, schedule_in: 2))
    |> Gits.Repo.transaction()

    :ok
  end
end
