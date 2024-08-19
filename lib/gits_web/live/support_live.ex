defmodule GitsWeb.SupportLive do
  require Ash.Query
  alias Gits.Storefront.TicketInvite
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket |> noreply()
  end

  def handle_event("send_invites", _unsigned_params, socket) do
    TicketInvite
    |> Ash.Query.for_read(:read)
    |> Ash.Query.load(customer: [:name, user: :email], ticket: [event: :account])
    |> Ash.Query.filter(state == :created)
    |> Ash.read!()
    |> Enum.each(fn invite ->
      subject = "You're Invited to The ZATechRadio 📻 Meet: Rooftop Edition"

      body =
        Gits.EmailTemplates.TicketInvite.render(
          title: subject,
          user_name: invite.customer.name,
          base_url: Application.get_env(:gits, :base_url),
          url: "/ticket-invite/#{invite.id}"
        )

      %{to: invite.customer.user.email, subject: subject, body: body}
      |> Gits.Workers.DeliverEmail.new()
      |> Oban.insert()
    end)

    socket |> noreply()
  end

  def render(assigns) do
    ~H"""
    <div class="p-20">
      <button class="rounded-lg border px-4 py-3 font-medium" phx-click="send_invites">
        Send invites
      </button>
    </div>
    """
  end
end
