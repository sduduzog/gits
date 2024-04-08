defmodule Gits.Auth.Senders.PasswordReset do
  use AshAuthentication.Sender
  use GitsWeb, :verified_routes
  import Swoosh.Email

  def send(%Gits.Auth.User{} = user, token, _opts) do
    Gits.Auth.Emails.deliver_password_reset(user, url(~p"/password-reset/#{token}"))
  end
end
