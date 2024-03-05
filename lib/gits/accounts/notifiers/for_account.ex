defmodule Gits.Accounts.Notifiers.ForAccount do
  use Ash.Notifier

  alias Gits.Accounts
  alias Gits.Accounts.Account
  alias Gits.Accounts.Role

  def notify(%Ash.Notifier.Notification{action: %{type: :create}, data: user}) do
    Account
    |> Ash.Changeset.new()
    |> Ash.Changeset.for_create(:create)
    |> Accounts.create!()
    |> Ash.Changeset.for_update(:foo, user_id: %{user_id: user.id})
    |> Gits.Accounts.update!()

    :ok
  end
end
