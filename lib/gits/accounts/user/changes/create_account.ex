defmodule Gits.Accounts.User.Changes.CreateAccount do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(
      changeset,
      fn _, result ->
        IO.inspect(result)
        {:ok, result}
      end
    )
  end
end
