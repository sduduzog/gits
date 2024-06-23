defmodule Gits.Storefront.Checks.TicketSaleEndDateIsAhead do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "ticket sale end date is ahead"
  end

  def match?(_actor, %{resource: Gits.Storefront.Ticket} = context, _options) do
    %{data: data} =
      context.changeset

    data.sale_ends_at
    |> case do
      nil ->
        false

      sale_ends_at ->
        sale_ends_at |> NaiveDateTime.after?(NaiveDateTime.local_now())
    end
  end

  def match?(_, _, _), do: false
end
