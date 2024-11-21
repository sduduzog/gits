defmodule Gits.Storefront.Order.Notifiers.OrderCompletedEmailNotifier do
  use Ash.Notifier
  alias Gits.Storefront.Order
  use Oban.Worker, max_attempts: 1

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{data: %Order{state: :completed, email: email}}) do
    %{email: email}
    |> __MODULE__.new()
    |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email}}) do
    Gits.Mailer.order_completed(email)
  end
end
