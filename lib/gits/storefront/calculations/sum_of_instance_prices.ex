defmodule Gits.Storefront.Calculations.SumOfInstancePrices do
  use Ash.Resource.Calculation
  require Decimal

  def load(_query, _opts, _context) do
    [instances: [:price]]
  end

  def calculate(records, _opts, _context) do
    records
    |> Enum.map(fn record ->
      record.instances
      |> Enum.reduce(Decimal.new("0"), fn instance, acc ->
        acc |> Decimal.add(instance.price)
      end)
    end)
  end
end
