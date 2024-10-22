defmodule Gits.Accounts.Senders.SendMagicLink do
  use AshAuthentication.Sender

  @impl true
  def send(email, token, _opts) do
    Gits.Emails.deliver_magic_link(email, token)
  end
end
