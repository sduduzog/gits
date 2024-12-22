defmodule Gits.Storefront.Order.Notifiers.OrderCompleted do
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
    Ash.get(Order, id, load: [:event, :ticket_types, :tickets])
    |> case do
      {:ok, order} ->
        %{ticket_types: ticket_types, tickets: tickets} = order

        tickets_summary =
          for type <- ticket_types do
            tickets = Enum.filter(tickets, &(&1.ticket_type_id == type.id))
            count = Enum.count(tickets)

            if count > 0 do
              {type.name, Decimal.mult(type.price, count), count}
            end
          end

        Gits.Mailer.order_completed(
          order.email |> to_string(),
          tickets_summary,
          order.total,
          order.event.name,
          order.id
        )

      {:error, error} ->
        {:error, error}
    end
  end
end
