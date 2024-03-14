defmodule Gits.Checks.CanCreateTicket do
  use Ash.Policy.SimpleCheck
  require Ash.Query
  alias Gits.Accounts.Role
  alias Gits.Accounts.User

  def match?(%User{} = actor, %{resource: Gits.Events.Ticket} = context, _) do
    user =
      actor
      |> Gits.Accounts.load!(
        roles:
          Role
          |> Ash.Query.filter(
            user_id: actor.id,
            account_id: context.changeset.arguments.event.account_id
          )
          |> Ash.Query.filter(type in [:owner])
      )

    user.roles != []
  end

  def match?(_actor, _context, _options), do: false
end
