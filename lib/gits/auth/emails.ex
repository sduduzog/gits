defmodule Gits.Auth.Emails do
  alias Gits.EmailTemplates.UserConfirmation
  import Swoosh.Email
  use GitsWeb, :verified_routes

  def deliver_password_reset_link(user, url) do
    deliver(user.email, "Password reset", """
    <a href="#{url}">#{url}</a>
    """)
  end

  def deliver_user_confirmation_link(user, url) do
    template =
      UserConfirmation.render(
        title: "Verify your email address",
        user_name: user.display_name,
        preview: "Click on the link to verify your email",
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
end
