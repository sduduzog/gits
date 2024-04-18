defmodule Gits.Checks.CanDestroy do
  use Ash.Policy.SimpleCheck

  def describe(_options) do
    "can destroy"
  end

  def match?(_actor, _context, _options) do
    true
  end
end
