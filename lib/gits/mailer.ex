defmodule Gits.Mailer do
  use Swoosh.Mailer, otp_app: :gits
  import Swoosh.Email

  def magic_link(token, to) do
    new()
    |> to(to)
    |> sender("auth")
    |> subject("Sign in to GiTS")
    |> render_body(:magic_link, %{token: token})
    |> premail()
    |> deliver()
  end

  def order_completed(to, tickets_summary, total, event_name, order_id) do
    new()
    |> to(to)
    |> sender("orders")
    |> subject("Order Completed Successfully")
    |> render_body(:order_completed, %{
      tickets_summary: tickets_summary,
      total: total,
      event_name: event_name,
      order_id: order_id
    })
    |> premail()
    |> deliver()
  end

  def refund_requested(to, otp, order_no) do
    new()
    |> to(to)
    |> sender("refunds")
    |> subject("Refund Requested")
    |> render_body(:refund_requested, %{otp: otp, order_no: order_no})
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

  defp sender(email, username) do
    host = Application.get_env(:gits, :host)

    from(email, {"GiTS", "#{username}@#{host}"})
  end
end
