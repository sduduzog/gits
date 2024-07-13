defmodule Gits.Storefront.Calculations.TicketToken do
  use Ash.Resource.Calculation
  require Decimal

  def load(_query, _opts, _context) do
    [:event]
  end

  def calculate(records, _opts, %{actor: user} = _context) do
    records
    |> Enum.map(fn record ->
      event = record.event |> Ash.load!(:keypair)

      Paseto.generate_token(
        "v2",
        "public",
        "#{record.id}:#{user.id}",
        event.keypair.secret_key
      )
    end)
  end
end
