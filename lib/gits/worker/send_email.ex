defmodule Gits.Worker.SendEmail do
  use Swoosh.Mailer, otp_app: :gits
  use Oban.Worker
  use GitsWeb, :verified_routes
  import Swoosh.Email

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: args,
        meta: %{
          "to" => to,
          "sender_name" => sender_name,
          "sender_email" => sender_email,
          "subject" => subject,
          "template" => template
        }
      }) do
    with {:ok, body} <- render_template(template, args) do
      new()
      |> to(to)
      |> from({sender_name, sender_email})
      |> subject(subject)
      |> html_body(body)
      |> deliver()
    end
  end

  def host_invite(to, host_id, host_name, invite_id) do
    host = Application.get_env(:gits, :host)

    %{host_name: host_name, invite_url: url(~p"/hosts/#{host_id}/join/#{invite_id}")}
    |> __MODULE__.new(
      meta: %{
        to: to,
        sender_name: "GiTS Team",
        sender_email: "hey@#{host}",
        subject: "Invitation to join #{host_name}",
        template: :host_invite
      }
    )
    |> Oban.insert()
  end

  defp render_template(template, args) do
    NodeJS.call({"email.mjs", :render_template}, [template, url(~p"/"), args],
      esm: true,
      binary: true
    )
  end
end
