defmodule Gits.Storefront.Event.Checks.ActorCanCreateEvent do
  alias Gits.Accounts.User
  alias Gits.Storefront.Event
  use Ash.Policy.SimpleCheck

  def describe(_) do
    "actor has a role that can create events"
  end

  def match?(actor, %{resource: Event}, _options) do
    Ash.load(actor, [:roles], actor: actor)
    |> case do
      {:ok, %User{roles: roles}} ->
        Enum.any?(roles, &Enum.member?([:owner], &1.type))

      _ ->
        false
    end
  end

  def match?(_, _, _), do: false
end
