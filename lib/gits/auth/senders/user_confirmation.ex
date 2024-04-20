defmodule Gits.Auth.Senders.UserConfirmation do
  use AshAuthentication.Sender
  use GitsWeb, :verified_routes

  def send(user, token, _opts) do
    Gits.Auth.Emails.deliver_user_confirmation_link(
      user,
      url(~p"/auth/user/confirm/?confirm=#{token}")
    )
  end
end
