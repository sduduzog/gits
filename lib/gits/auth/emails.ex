defmodule Gits.Auth.Emails do
  import Swoosh.Email
  use GitsWeb, :verified_routes

  def deliver_magic_link(to, token) do
    body = Gits.EmailTemplates.render_magic_link(token)

    new()
    |> to(to_string(to))
    |> subject("Sign in to GiTS")
    |> html_body(body)
    |> deliver()
  end

  def deliver_email_confirmation_link(to, token) do
    body = Gits.EmailTemplates.render_email_confirmation_link(token)

    new()
    |> to(to_string(to))
    |> subject("Sign in to GiTS")
    |> html_body(body)
    |> deliver()
  end

  defp deliver(%Swoosh.Email{} = email) do
    sender = "hey@" <> GitsWeb.Endpoint.host()

    email
    |> from({"GiTS", sender})
    |> Gits.Mailer.deliver()
    |> case do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end
end
