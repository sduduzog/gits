defmodule Gits.Storefront.Calculations.MaskId do
  use Ash.Resource.Calculation

  def load(_query, _opts, _context) do
    [:id]
  end

  def calculate(records, _opts, _context) do
    Enum.map(records, fn record ->
      Sqids.new!() |> Sqids.encode!([record.id])
    end)
  end
end
