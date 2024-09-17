defmodule Gits.Auth.Emails do
  alias Gits.EmailTemplates.PasswordReset
  alias Gits.EmailTemplates.UserConfirmation
  import Swoosh.Email
  use GitsWeb, :verified_routes

  def deliver_password_reset_link(user, url) do
    template =
      PasswordReset.render(
        title: "Reset your password",
        user_name: user.display_name,
        base_url: Application.get_env(:gits, :base_url),
        url: url
      )

    deliver(user.email, "Reset your password", template)
  end

  def deliver_user_confirmation_link(user, url) do
    template =
      UserConfirmation.render(
        title: "Verify your email address",
        user_name: user.display_name,
        base_url: Application.get_env(:gits, :base_url),
        url: url
      )

    deliver(user.email, "Verify your email address", template)
  end

  defp deliver(to, subject, body) do
    sender = Application.get_env(:gits, :sender_email)

    new()
    |> from({"GiTS", sender})
    |> to(to_string(to))
    |> subject(subject)
    |> html_body(body)
    |> Gits.Mailer.deliver()
  end

  def deliver_magic_link(to, token) do
    body = Gits.EmailTemplates.render_magic_link(token)

    new()
    |> from({"GiTS", "hey@gits.co.za"})
    |> to(to_string(to))
    |> subject("Sign in to GiTS")
    |> html_body(body)
    |> deliver()
  end

  def deliver_email_confirmation_link(to, token) do
    body = Gits.EmailTemplates.render_magic_link(token)

    new()
    |> from({"GiTS", "hey@gits.co.za"})
    |> to(to_string(to))
    |> subject("Sign in to GiTS")
    |> html_body(body)
    |> deliver()
  end

  defp deliver(%Swoosh.Email{} = email) do
    email
    |> Gits.Mailer.deliver()
    |> case do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end
end
