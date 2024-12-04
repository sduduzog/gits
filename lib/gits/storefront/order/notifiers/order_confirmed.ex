defmodule Gits.Storefront.Order.Notifiers.OrderConfirmed do
  use Ash.Notifier
  use Oban.Worker, max_attempts: 1

  @impl Ash.Notifier
  def notify(_) do
  end
end
