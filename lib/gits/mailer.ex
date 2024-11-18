defmodule Gits.Mailer do
  use Swoosh.Mailer, otp_app: :gits
  import Swoosh.Email

  def magic_link(token, to) do
    config = Application.get_env(:gits, Gits.Mailer)

    sender = "auth@#{config[:domain]}"

    new()
    |> to(to)
    |> from({"GiTS", sender})
    |> subject("Sign in to GiTS")
    |> render_body(:magic_link, %{token: token})
    |> premail()
    |> deliver()
  end

  defp render_body(email, template, args) do
    heex = apply(GitsWeb.EmailHTML, template, [args])
    html_body(email, render_component(heex))
  end

  defp render_component(heex) do
    heex
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.chardata_to_string()
  end

  defp premail(email) do
    text = Premailex.to_text(email.html_body)

    email
    |> text_body(text)
  end
end
