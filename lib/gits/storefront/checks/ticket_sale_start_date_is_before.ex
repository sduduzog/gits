defmodule Gits.Storefront.Checks.TicketSaleStartDateIsBefore do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "ticket sale start date is before"
  end

  def match?(_actor, %{resource: Gits.Storefront.Ticket} = context, _options) do
    %{data: data} =
      context.changeset

    data.sale_starts_at
    |> case do
      nil ->
        false

      sale_starts_at ->
        sale_starts_at |> NaiveDateTime.before?(NaiveDateTime.local_now())
    end
  end

  def match?(_, _, _), do: false
end
