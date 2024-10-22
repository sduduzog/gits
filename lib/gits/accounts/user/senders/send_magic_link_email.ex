defmodule Gits.Accounts.User.Senders.SendMagicLinkEmail do
  @moduledoc """
  Sends a magic link email
  """

  import Swoosh.Email
  use AshAuthentication.Sender

  @impl true
  def send(user_or_email, token, _) do
    # if you get a user, its for a user that already exists
    # if you get an email, the user does not exist yet
    # Example of how you might send this email
    # Gits.Accounts.Emails.send_magic_link_email(
    #   user_or_email,
    #   token
    # )

    email =
      case user_or_email do
        %{email: email} -> email
        email -> email
      end

    new()
    |> to(email)
    |> text_body("""
    Welcome to GiTS

    To finish signing in, use the following url bellow:

    #{"/auth/user/magic_link?token=#{}"}
    """)
    |> put_provider_option(:custom_vars, %{"url" => "/auth/user/magic_link/?token=#{token}"})
    |> put_provider_option(:template_name, "magic-link")
    |> put_provider_option(:template_options, %{version: "initial"})
  end
end
