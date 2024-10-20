defmodule Gits.Storefront.Calculations.TicketToken do
  use Ash.Resource.Calculation
  require Decimal

  def load(_query, _opts, _context) do
    []
  end

  def calculate(records, _opts, %{actor: user} = _context) do
    records
    |> Enum.map(fn record ->
      do_thing(record, user)
    end)
  end

  defp do_thing(record, user) do
    ExBase58.encode!("#{record.id}:#{user.id}")
  end
end
