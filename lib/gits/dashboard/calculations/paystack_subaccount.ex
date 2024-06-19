defmodule Gits.Dashboard.Calculations.PaystackSubaccount do
  alias Gits.PaystackApi
  use Ash.Resource.Calculation

  def load(_query, _opts, _context) do
    [:paystack_subaccount_code]
  end

  def calculate(records, _opts, _context) do
    records
    |> Enum.map(fn record ->
      PaystackApi.fetch_subaccount(record.paystack_subaccount_code)
      |> case do
        {:ok, subaccount} -> subaccount
        _ -> nil
      end
    end)
  end
end
