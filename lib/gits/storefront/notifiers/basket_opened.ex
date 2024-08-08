defmodule Gits.Storefront.Notifiers.BasketOpened do
  use Ash.Notifier
  require Logger

  alias Gits.Workers.ReclaimBasket

  def notify(%Ash.Notifier.Notification{data: data}) do
    [
      reclaim_open_basket_timeout: open_basket,
      reclaim_payment_started_basket_timeout: payment_started_basket
    ] =
      Application.get_env(:gits, :workers)

    Ecto.Multi.new()
    |> Oban.insert(
      :open_basket_job,
      ReclaimBasket.new(%{id: data.id, state: :open}, schedule_in: open_basket)
    )
    |> Oban.insert(
      :payment_started_basket_job,
      ReclaimBasket.new(%{id: data.id, state: :payment_started},
        schedule_in: payment_started_basket
      )
    )
    |> Gits.Repo.transaction()

    :ok
  end
end
