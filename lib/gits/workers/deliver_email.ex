defmodule Gits.Workers.DeliverEmail do
  use Oban.Worker, queue: :mailers

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    sender = Application.get_env(:gits, :sender_email)

    Swoosh.Email.new()
    |> Swoosh.Email.from({"GiTS", sender})
    |> Swoosh.Email.to(to_string(args["to"]))
    |> Swoosh.Email.subject(args["subject"])
    |> Swoosh.Email.html_body(args["body"])
    |> Gits.Mailer.deliver()
  end
end
