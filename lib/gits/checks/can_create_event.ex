defmodule Gits.Checks.CanCreateEvent do
  use Ash.Policy.SimpleCheck
  require Ash.Query
  alias Gits.Accounts.Role
  alias Gits.Accounts.User

  def describe(_) do
    ""
  end

  def match?(%User{} = actor, %{resource: Gits.Events.Event} = context, _) do
    user =
      actor
      |> Gits.Accounts.load!(
        roles:
          Role
          |> Ash.Query.filter(
            user_id: actor.id,
            account_id: context.changeset.arguments.account.id
          )
          |> Ash.Query.filter(type in [:owner, :admin])
      )

    user.roles != []
  end

  def match?(_actor, _context, _options), do: false
end
