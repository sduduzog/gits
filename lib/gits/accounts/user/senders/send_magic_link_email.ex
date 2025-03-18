defmodule Gits.Accounts.User.Senders.SendMagicLinkEmail do
  use AshAuthentication.Sender

  @impl true
  def send(user_or_email, token, _) do
    email =
      case user_or_email do
        %{email: email} -> email |> to_string()
        email -> email
      end

    Gits.Mailer.deliver_magic_link(email, token)
  end
end
