defmodule Gits.Auth.Senders.SendMagicLink do
  use AshAuthentication.Sender

  @impl true
  def send(user, token, _opts) do
    Gits.Auth.Emails.deliver_magic_link(user.email, token)
  end
end
