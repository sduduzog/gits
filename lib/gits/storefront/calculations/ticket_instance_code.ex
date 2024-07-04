defmodule Gits.Storefront.Calculations.TicketInstanceCode do
  use Ash.Resource.Calculation
  require Decimal

  def load(_query, _opts, _context) do
    [:basket]
  end

  def calculate(records, _opts, _context) do
    records
    |> Enum.map(fn record ->
      Paseto.V2.encrypt("test", record.basket.id |> String.replace("-", ""))
    end)
  end
end
