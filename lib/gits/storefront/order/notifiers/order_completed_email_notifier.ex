defmodule Gits.Storefront.Order.Notifiers.OrderCompletedEmailNotifier do
  use Ash.Notifier
  alias Gits.Storefront.Order
  use Oban.Worker, max_attempts: 1

  @impl Ash.Notifier
  def notify(%Ash.Notifier.Notification{data: %Order{state: :completed} = order}) do
    %{id: order.id}
    |> __MODULE__.new()
    |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    Order
    |> Ash.get(id, load: [:event, :ticket_types, :tickets])
    |> case do
      {:ok, order} ->
        %{ticket_types: ticket_types, tickets: tickets} = order

        tickets_summary =
          for type <- ticket_types do
            tickets = Enum.filter(tickets, &(&1.ticket_type_id == type.id))
            count = Enum.count(tickets)

            if count > 0 do
              {type.name, type.price, count}
            end
          end

        total =
          for {_, price, _} <- tickets_summary, reduce: Decimal.new("0") do
            acc ->
              acc |> Decimal.add(price)
          end

        Gits.Mailer.order_completed(
          order.email |> to_string(),
          tickets_summary,
          total,
          order.event.name,
          order.number
        )

      {:error, error} ->
        {:error, error}
    end
  end
end
