defmodule Gits.Auth.Senders.UserConfirmation do
  use AshAuthentication.Sender
  use GitsWeb, :verified_routes
  alias Gits.Auth.Emails

  def send(user, token, _opts) do
    case Emails.deliver_user_confirmation_link(
           user,
           url(~p"/auth/user/confirm/?confirm=#{token}")
         ) do
      {:ok, _} -> :ok
      _ -> :error
    end
  end
end
