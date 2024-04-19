defmodule Gits.Auth.Senders.EmailConfirmation do
  use AshAuthentication.Sender
  use GitsWeb, :verified_routes

  def send(user, token, _opts) do
    Gits.Auth.Emails.deliver_email_confirmation_link(
      user,
      url(~p"/auth/user/confirm/?confirm=#{token}")
    )
    |> IO.inspect()
  end
end
