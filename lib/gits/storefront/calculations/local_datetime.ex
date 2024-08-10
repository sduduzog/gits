defmodule Gits.Storefront.Calculations.LocalDatetime do
  use Ash.Resource.Calculation

  def load(_query, opts, _context) do
    [opts[:attribute]]
  end

  def calculate(records, opts, _context) do
    time_zone = Application.get_env(:gits, :time_zone)

    Enum.map(records, fn record ->
      record
      |> Map.get(opts[:attribute])
      |> utc_to_naive(time_zone)
    end)
  end

  def utc_to_naive(%DateTime{} = datetime, time_zone) do
    datetime
    |> DateTime.shift_zone!(time_zone)
    |> DateTime.to_naive()
  end

  def utc_to_naive(_, _) do
    nil
  end
end
