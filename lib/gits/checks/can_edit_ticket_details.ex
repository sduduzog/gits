defmodule Gits.Checks.CanEditTicketDetails do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    ""
  end

  def match?(_actor, _context, _options), do: false
end
