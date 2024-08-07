defmodule Gits.Checks.ActorIsObanJob do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "actor is oban job"
  end

  def match?(%Oban.Job{}, _context, _options) do
    true
  end

  def match?(_, _, _) do
    "foooooooooooooooooooooooo" |> IO.puts()
    false
  end
end
