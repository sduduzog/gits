defmodule Gits.Checks.CanAcceptInvite do
  use Ash.Policy.SimpleCheck
  require Ash.Query
  alias Gits.Accounts.User

  def describe(_) do
    ""
  end

  def match?(%User{} = actor, %{resource: Gits.Accounts.Invite} = context, _) do
    actor.email == context.changeset.data.email
  end

  def match?(_actor, _context, _options), do: false
end
