defmodule Gits.Checks.TicketsLimitedPerUser do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "tickets limited per user"
  end

  def match?(_actor, _context, _options) do
    true
  end
end
