defmodule Gits.Dashboard.Changes.SendDashboardInvite do
  use GitsWeb, :verified_routes
  use Ash.Resource.Change
  alias Gits.EmailTemplates.AccountInvitation
  alias Gits.Workers.DeliverEmail

  def change(changeset, _opts, %{actor: actor}) do
    changeset
    |> Ash.Changeset.after_action(fn _, result ->
      invite =
        result
        |> Ash.load!(:account, actor: actor)

      subject = "You've been invited to join #{invite.account.name}'s GiTS account"

      body =
        AccountInvitation.render(
          title: subject,
          sender: actor.display_name,
          account_name: invite.account.name,
          role: invite.role,
          base_url: Application.get_env(:gits, :base_url),
          url: url(~p"/accounts/#{invite.account.id}/team/invites/#{invite.id}")
        )

      %{to: invite.email, subject: subject, body: body}
      |> DeliverEmail.new()
      |> Oban.insert()

      {:ok, result}
    end)
  end
end
