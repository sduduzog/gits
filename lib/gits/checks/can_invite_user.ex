defmodule Gits.Checks.CanInviteUser do
  use Ash.Policy.SimpleCheck

  require Ash.Query
  alias Gits.Accounts.Role
  alias Gits.Accounts.User

  def describe(_) do
    ""
  end

  def match?(%User{} = actor, %{resource: Gits.Accounts.Invite} = context, _) do
    IO.inspect(actor)

    user =
      Gits.Accounts.load!(
        actor,
        roles:
          Ash.Query.filter(
            Role,
            user_id: actor.id,
            account_id: context.changeset.arguments.account.id
          )
          |> Ash.Query.filter(type in [:owner, :admin])
      )

    user.roles != []
  end

  def match?(_actor, _context, _options), do: false
end
