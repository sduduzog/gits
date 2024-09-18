defmodule Gits.Auth.Senders.SendEmailConfirmationLink do
  use AshAuthentication.Sender

  @impl true
  def send(user, token, _opts) do
    Gits.Auth.Emails.deliver_email_confirmation_link(user.email, token)
  end
end
