defmodule Gits.Storefront.Calculations.QrCode do
  use Ash.Resource.Calculation
  require Decimal

  def load(_query, _opts, _context) do
    []
  end

  def calculate(records, _opts, %{actor: user} = _context) do
    user
    |> Ash.load([:customer], actor: user)
    |> case do
      {:ok, user} ->
        records
        |> Enum.map(fn
          record ->
            ExBase58.encode!("#{record.id}:#{user.customer.id}")
        end)

      _ ->
        records
        |> Enum.map(fn record ->
          nil
        end)
    end
  end
end
