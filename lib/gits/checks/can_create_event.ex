defmodule Gits.Checks.CanCreateEvent do
  use Ash.Policy.SimpleCheck
  require Ash.Query
  alias Gits.Accounts.Role
  alias Gits.Accounts.User

  def match?(%User{} = actor, %{resource: Gits.Events.Event} = context, options) do
    IO.inspect(context)

    user =
      actor
      |> Gits.Accounts.load!(
        roles:
          Role
          |> Ash.Query.filter(
            user_id: actor.id,
            account_id: context.changeset.arguments.account.id
          )
          |> Ash.Query.filter(type in [:owner])
      )

    user.roles != []
  end

  def match?(_actor, _context, _options), do: false
end
