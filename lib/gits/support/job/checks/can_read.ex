defmodule Gits.Support.Job.Checks.CanRead do
  alias Gits.Support.Admin
  alias Gits.Accounts.User
  use Ash.Policy.SimpleCheck

  def describe(_opts) do
    ""
  end

  def match?(%User{} = actor, _, _) do
    Ash.load(actor, [:admin])
    |> case do
      {:ok, %User{admin: nil}} -> false
      {:ok, %User{admin: %Admin{}}} -> true
    end
  end

  def match?(_, _, _) do
    false
  end
end
