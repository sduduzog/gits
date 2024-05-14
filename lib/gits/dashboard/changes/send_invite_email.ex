defmodule Gits.Dashboard.Changes.SendInviteEmail do
  use GitsWeb, :verified_routes
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _, result ->
      %{
        url: url(~p"/accounts/#{result.account_id}/invites/#{result.id}"),
        email: result.email |> to_string
      }
      |> Gits.Workers.SendDashboardInvite.new()
      |> Oban.insert()

      {:ok, result}
    end)
  end
end