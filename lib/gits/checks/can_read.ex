defmodule Gits.Checks.CanRead do
  use Ash.Policy.SimpleCheck

  def describe(options) do
    IO.inspect(options)
    "can read"
  end

  def match?(_actor, _context, _options) do
    false
  end
end
