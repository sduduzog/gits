defmodule Gits.Accounts.Invite.Changes.CreateInvite do
  use Ash.Resource.Change
  use GitsWeb, :verified_routes
  alias Gits.Accounts.Invite

  import Swoosh.Email

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.after_action(fn _, %Invite{} = result ->

      email =
        new()
        |> to(result.email |> to_string)
        |> from({"Gits", "hey@gits.co.za"})
        |> subject("Invitation")
        |> text_body("""
        Hi there,

        You've been invited to join a GiTS Account for the role: #{result.role}

        <a href="#{url(~p"/accounts/#{result.account_id}/invites/#{result.id}")}">view invitation</a>

        Thanks
        """)

      with {:ok, _metadata} <- Gits.Mailer.deliver(email) do
        :ok
      end

      {:ok, result}
    end)
  end
end
