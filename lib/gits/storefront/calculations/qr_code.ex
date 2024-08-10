defmodule Gits.Storefront.Calculations.QrCode do
  use Ash.Resource.Calculation
  require Decimal

  def load(_query, _opts, _context) do
    []
  end

  def calculate(records, _opts, %{actor: user} = _context) do
    records
    |> Enum.map(fn record ->
      ExBase58.encode!("#{record.id}:#{user.id}")
    end)
  end
end
