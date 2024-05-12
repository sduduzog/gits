defmodule Gits.Dashboard.Senders.InviteLink do
  use AshAuthentication.Sender
  use GitsWeb, :verified_routes

  def send(user, token, _opts) do
    # case Gits.Auth.Emails.deliver_user_confirmation_link(
    #        user,
    #        url(~p"/auth/user/confirm/?confirm=#{token}")
    #      ) do
    #   {:ok, _} -> :ok
    #   _ -> :error
    # end
  end
end
