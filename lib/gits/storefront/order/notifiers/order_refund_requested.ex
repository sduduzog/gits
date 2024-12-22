defmodule Gits.Storefront.Order.Notifiers.OrderRefundRequested do
  require Decimal
  use Ash.Notifier
  alias Gits.Storefront.Order
  use Oban.Worker, max_attempts: 1

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{data: %Order{state: :completed} = order}) do
    %{id: order.id}
    |> __MODULE__.new()
    |> Oban.insert()
  end

  def notify(_) do
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    Ash.get(Order, id)
    |> case do
      {:ok, order} ->
        otp =
          NimbleTOTP.verification_code(order.requested_refund_secret, period: 60 * 30)

        Gits.Mailer.refund_requested(to_string(order.email), otp, order.number)

      {:error, error} ->
        {:error, error}
    end
  end
end
