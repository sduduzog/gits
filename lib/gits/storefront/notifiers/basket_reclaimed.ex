defmodule Gits.Storefront.Notifiers.BasketReclaimed do
  use Ash.Notifier
  require Logger

  alias Gits.Workers.RefundBasket

  def notify(%Ash.Notifier.Notification{data: data}) do
    Ecto.Multi.new()
    |> Oban.insert(
      :refund_job,
      RefundBasket.new(%{id: data.id})
    )
    |> Gits.Repo.transaction()

    :ok
  end
end
