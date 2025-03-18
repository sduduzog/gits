defmodule Gits.Mailer do
  use Swoosh.Mailer, otp_app: :gits
  use GitsWeb, :verified_routes
  use Oban.Worker
  import Swoosh.Email

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
    |> deliver()
  end

  def refund_requested(to, otp, order_no) do
    new()
    |> to(to)
    |> sender("refunds")
    |> subject("Refund Requested")
    |> render_body(:refund_requested, %{otp: otp, order_no: order_no})
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

  def deliver_magic_link(to, token) do
    meta = %{subject: "Sign in to GiTS", to: to, sender: :auth}

    %{template: :magic_link, url: url(~p"/auth/user/magic_link?token=#{token}")}
    |> __MODULE__.new(meta: meta)
    |> Oban.insert()
  end

  def deliver_host_invite(to, host_handle, host_name, invite_id) do
    meta = %{subject: "Invitation to join #{host_name}", to: to, sender: :team}

    %{
      template: :host_invite,
      host_name: host_name,
      invite_url: url(~p"/hosts/#{host_handle}/join/#{invite_id}")
    }
    |> __MODULE__.new(meta: meta)
    |> Oban.insert()
  end

  defp deliver_email(to, sender_key, subject, body) do
    new()
    |> to(to)
    |> sender(sender_key)
    |> subject(subject)
    |> html_body(body)
    |> deliver()
  end

  def render_template(%{"template" => "magic_link", "url" => url}) do
    render_template(
      :magic_link,
      "Sign in to GiTS",
      nil,
      %{url: url}
    )
  end

  def render_template(%{
        "template" => "host_invite",
        "host_name" => host_name,
        "invite_url" => invite_url
      }) do
    render_template(
      :host_invite,
      "Invitation to join #{host_name}",
      nil,
      %{host_name: host_name, invite_url: invite_url}
    )
  end

  defp render_template(template_name, title, preheader, data) do
    NodeJS.call(
      {"email.mjs", :render_template},
      [template_name, url(~p"/"), title, preheader, data],
      esm: true,
      binary: true
    )
  end

  defp sender(email, "auth") do
    host = Application.get_env(:gits, :host)

    from(email, {"GiTS Auth", "auth@#{host}"})
  end

  defp sender(email, "team") do
    host = Application.get_env(:gits, :host)

    from(email, {"GiTS Team", "hey@#{host}"})
  end

  def perform(%Oban.Job{args: args, meta: meta}) do
    with {:ok, body} <- render_template(args) do
      deliver_email(meta["to"], meta["sender"], meta["subject"], body)
    end
  end
end
