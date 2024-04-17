defmodule Gits.Storefront.Checks.ActorIsCustomer do
  alias Gits.Storefront.Customer
  use Ash.Policy.SimpleCheck

  def describe(_options) do
    "he bebe"
  end

  def match?(%Customer{}, _context, _options) do
    true
  end

  def match?(_, _, _) do
    false
  end
end
