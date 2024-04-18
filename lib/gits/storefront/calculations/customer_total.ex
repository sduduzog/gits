defmodule Gits.Storefront.Calculations.CustomerTotal do
  use Ash.Resource.Calculation

  def load(_query, _opts, _context) do
    [:price, :customer_instance_count]
  end

  def calculate(records, _opts, _context) do
    Enum.map(records, fn record ->
      record.price * record.customer_instance_count
    end)
  end
end
