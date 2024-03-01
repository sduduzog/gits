defmodule Gits.Accounts.User.Senders.AccountConfirmationSender do
  use AshAuthentication.Sender
  use GitsWeb, :verified_routes
  import Swoosh.Email

  def send(user, token, _) do
    email =
      new()
      |> to(user.email |> to_string)
      |> from({"Gits", "hey@gits.co.za"})
      |> subject("Email confirmation")
      |> text_body("""
      Hi there,

      You can confirm your account by visiting the URL below:gen_fsm

      <a href="#{url(~p"/auth/user/confirm?confirm=#{token}")}">link</a>

      Thanks
      """)

    with {:ok, _metadata} <- Gits.Mailer.deliver(email) do
      :ok
    end
  end
end
