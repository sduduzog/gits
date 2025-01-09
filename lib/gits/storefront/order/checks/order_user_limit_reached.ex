defmodule Gits.Storefront.Order.Checks.OrderUserLimitReached do
  require Ash.Query
  alias Gits.Storefront.Ticket
  alias Gits.Storefront.TicketType
  alias Gits.Storefront.Order
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "order user limit reached"
  end

  def match?(actor, %{resource: Order, changeset: changeset}, _) do
    ticket_type =
      Ash.Changeset.get_argument(changeset, :ticket_type)

    Ash.load(
      changeset.data,
      [
        ticket_types:
          Ash.Query.filter(TicketType, id == ^ticket_type["id"])
          |> Ash.Query.load(
            tickets:
              Ash.Query.filter(Ticket, order.email == ^changeset.data.email)
              |> Ash.Query.filter(state != :released)
          )
      ],
      actor: actor
    )
    |> case do
      {:ok, %Order{ticket_types: [type]}} ->
        Enum.count(type.tickets) >= type.limit_per_user

      _ ->
        true
    end
  end
end
