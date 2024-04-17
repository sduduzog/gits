defmodule Gits.Storefront.Checks.ActorHasFoo do
  use Ash.Policy.SimpleCheck

  def describe(_options) do
    "he bebe"
  end

  def match?(_actor, _context, _options) do
    true
  end
end
