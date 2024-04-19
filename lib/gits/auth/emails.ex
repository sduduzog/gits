defmodule Gits.Auth.Emails do
  import Swoosh.Email
  use GitsWeb, :verified_routes

  def deliver_password_reset_link(user, url) do
    deliver(user.email, "Password reset", """
    <a href="#{url}">#{url}</a>
    """)
  end

  def deliver_magic_link(user, url) do
    deliver(user.email, "Magic Link", """
    <a href="#{url}">#{url}</a>
    """)
  end

  def deliver_email_confirmation_link(user, url) do
    deliver(user.email, "Account confirmation", """
    <a href="#{url}">#{url}</a>
    """)
  end

  defp deliver(to, subject, body) do
    new()
    |> from({"GiTS", "hey@sandbox8ae8eee3fcff4f77a8def1ee763a4277.mailgun.org"})
    |> to(to_string(to))
    |> subject(subject)
    |> html_body(body)
    |> Gits.Mailer.deliver()
  end
end
