defmodule Gits.Accounts.User.Senders.SendPasswordResetEmail do
  use AshAuthentication.Sender
  use GitsWeb, :verified_routes
  import Swoosh.Email

  def send(user, token, _) do
    email =
      new()
      |> to(user.email |> to_string)
      |> from({"Gits", "hey@gits.co.za"})
      |> subject("Reset password request")
      |> text_body("""
      Hi #{user.display_name},


      <a href="#{url(~p"/password-reset/#{token}")}">Click here to reset password</a>

      Thanks
      """)

    with {:ok, _metadata} <- Gits.Mailer.deliver(email) do
      :ok
    end
  end
end
