defmodule Gits.Workers.SendDashboardInvite do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    body = """
    Hi there,
    You've been invited to join a GiTS Account for the role
    <a href="#{args["url"]}">view invitation</a>
    Thanks
    """

    %{to: args["email"], subject: "Accept this invitation", body: body}
    |> Gits.Workers.DeliverEmail.new()
    |> Oban.insert()
  end
end
