defmodule Gits.Accounts.User.Changes.CreateAccount do
  use Ash.Resource.Change
  alias Gits.Accounts.User
  alias Gits.Accounts.Account
  alias Gits.Accounts.Role

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn %{action_type: action_type}, %User{} = result ->
      if action_type == :create do
        account =
          Account
          |> Ash.Changeset.new()
          |> Ash.Changeset.for_create(:create)
          |> Gits.Accounts.create!()

        Role
        |> Ash.Changeset.new(%{account_id: account.id, user_id: result.id})
        |> Ash.Changeset.for_create(:create)
        |> Gits.Accounts.create!()
      end

      {:ok, result}
    end)
  end
end
