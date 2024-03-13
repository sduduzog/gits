defmodule Gits.Checks.CanEditEventDetails do
  use Ash.Policy.SimpleCheck

  def match?(_actor, _context, _options), do: false
end
