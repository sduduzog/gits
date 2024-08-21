defmodule Gits.Storefront.Notifiers.InviteCreated do
  use Ash.Notifier
  require Logger
  use GitsWeb, :verified_routes

  alias Gits.Workers.DeliverEmail

  def notify(%Ash.Notifier.Notification{data: data}) do
    data
    |> Ash.load(customer: [:name, user: :email], ticket: [event: :account])
    |> case do
      {:ok, invite} ->
        subject = "You're Invited. The ZATechRadio 📻 Meet: Rooftop Edition"

        uri = url(~p"/ticket-invite/#{invite.id}")

        body =
          Gits.EmailTemplates.TicketInvite.render(
            title: subject,
            base_url: Application.get_env(:gits, :base_url),
            url: uri
          )

        %{to: invite.receipient_email, subject: subject, body: body}
        |> Gits.Workers.DeliverEmail.new()
        |> Oban.insert()

        :ok

      _ ->
        :error
    end
  end
end
