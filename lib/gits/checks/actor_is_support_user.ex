defmodule Gits.Checks.ActorIsSupportUser do
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "actor is support user"
  end

  def match?(_, _, _) do
    false
  end
end
