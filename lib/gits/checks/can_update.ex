defmodule Gits.Checks.CanUpdate do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "can update"
  end

  def match?(_actor, _context, _options) do
    true
  end
end
