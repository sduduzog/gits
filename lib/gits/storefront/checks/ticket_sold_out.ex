defmodule Gits.Storefront.Checks.TicketSoldOut do
  require Ash.Query
  alias Gits.Storefront.{Ticket, TicketInstance}
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "ticket is sold out"
  end

  def match?(actor, %{resource: Gits.Storefront.Ticket} = context, _options) do
    context.changeset.data
    |> Ash.load(
      [
        instances:
          TicketInstance
          |> Ash.Query.filter(basket.state in [:open, :settled_for_free, :settled_for_payment])
          |> Ash.Query.load(customer: [:user])
      ],
      actor: actor
    )
    |> case do
      {:ok, ticket} ->
        user_total =
          ticket.instances |> Enum.count(&(&1.customer.user.id == actor.id))

        total = ticket.instances |> Enum.count()

        max_per_user_reached =
          ticket.allowed_quantity_per_user > 0 and user_total >= ticket.allowed_quantity_per_user

        total_reached = total >= ticket.total_quantity

        max_per_user_reached or total_reached
    end
  end

  def match?(_, _, _), do: true
end
