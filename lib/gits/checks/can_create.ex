defmodule Gits.Checks.CanCreate do
  use Ash.Policy.SimpleCheck
  alias Gits.Auth.User

  def describe(_options) do
    "can create"
  end

  def match?(%User{}, %{resource: Gits.Dashboard.Account}, _options) do
    true
  end

  def match?(
        %User{},
        %{
          resource: Gits.Dashboard.Member,
          changeset: %{context: %{accessing_from: %{source: Gits.Dashboard.Account}}}
        },
        _options
      ) do
    true
  end

  def match?(
        %User{},
        %{
          resource: Gits.Storefront.Event,
          changeset: %{context: %{accessing_from: %{source: Gits.Dashboard.Account}}}
        },
        _options
      ) do
    true
  end

  def match?(_, _, _) do
    false
  end
end
