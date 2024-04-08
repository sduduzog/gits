defmodule Gits.Auth.Senders.MagicLink do
  use AshAuthentication.Sender
  use GitsWeb, :verified_routes

  def send(user, token, _opts) do
    Gits.Auth.Emails.deliver_magic_link(user, url(~p"/auth/user/magic_link/?token=#{token}"))
  end
end
