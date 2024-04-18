defmodule Gits.Checks.CanRead do
  use Ash.Policy.SimpleCheck

  def describe(_options) do
    "can read"
  end

  def match?(_actor, _context, _options) do
    true
  end
end