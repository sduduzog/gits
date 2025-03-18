defmodule Gits.Mailer do
  use Swoosh.Mailer, otp_app: :gits
  use GitsWeb, :verified_routes
  use Oban.Worker
  import Swoosh.Email

  def magic_link(token, to) do
    new()
    |> to(to)
    |> sender("auth")
    |> subject("Sign in to GiTS")
    |> render_body(:magic_link, %{token: token})
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

  defp sender(email, username) do
    host = Application.get_env(:gits, :host)

    from(email, {"GiTS", "#{username}@#{host}"})
  end

  def deliver_magic_link(to, token) do
    meta = %{subject: "Sign in to GiTS", to: to, sender: :auth}

    %{template: :magic_link, url: url(~p"/auth/user/magic_link?token=#{token}")}
    |> __MODULE__.new(meta: meta)
    |> Oban.insert()
  end

  def deliver_host_invite(to, host_id, host_name, invite_id) do
    host = Application.get_env(:gits, :host)

    %{host_name: host_name, invite_url: url(~p"/hosts/#{host_id}/join/#{invite_id}")}
    |> queue(%{
      to: to,
      sender_name: "GiTS Team",
      sender_email: "hey@#{host}",
      subject: "Invitation to join #{host_name}",
      template: :host_invite
    })
  end

  defp queue(args, meta) do
    __MODULE__.new(args, meta: meta) |> Oban.insert()
  end

  def render_template(:magic_link, url) do
    render_template(
      :magic_link,
      "Sign in to GiTS",
      nil,
      %{url: url}
    )
  end

  def render_template("host_invite", host_name, invite_url) do
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

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"template" => "magic_link", "url" => url}, meta: meta}) do
    with {:ok, body} <- render_template(:magic_link, url) do
      new()
      |> to(meta["to"])
      |> sender(meta["sender"])
      |> subject(meta["subject"])
      |> html_body(body)
      |> deliver()
    end
  end
end
