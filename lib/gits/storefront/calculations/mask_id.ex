defmodule Gits.Storefront.Calculations.MaskId do
  use Ash.Resource.Calculation

  def load(_query, _opts, _context) do
    [:id]
  end

  def calculate(records, _opts, _context) do
    Enum.map(records, &encode/1)
  end

  def encode(id) do
    Sqids.new!() |> Sqids.encode!([id])
  end
end
