defmodule GitsWeb.DashboardLive.TicketInvitesViaEmail do
  require Ash.Query
  alias Gits.Storefront.{Customer, Ticket, TicketInvite}
  use GitsWeb, :dashboard_live_view

  def handle_params(unsigned_params, _uri, socket) do
    socket
    |> assign(:emails, [])
    |> assign(:event_id, unsigned_params["event_id"])
    |> assign(:ticket_id, unsigned_params["ticket_id"])
    |> assign(:form, %{"email" => ""})
    |> update_invites(socket.assigns.current_user)
    |> noreply()
  end

  def handle_event("add_email", %{"email" => email}, socket) do
    %{ticket_id: ticket_id, current_user: user} =
      socket.assigns

    ticket =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id == ^ticket_id)
      |> Ash.read_one!(actor: user)

    user = socket.assigns.current_user

    Customer
    |> Ash.Query.for_read(:read, %{}, actor: user)
    |> Ash.Query.filter(user.email == ^email)
    |> Ash.read_one()
    |> case do
      {:ok, %Customer{} = customer} ->
        TicketInvite
        |> Ash.Changeset.for_create(:create, %{customer: customer, ticket: ticket}, actor: user)
        |> Ash.create()

        socket

      _ ->
        TicketInvite
        |> Ash.Changeset.for_create(:email_only, %{receipient_email: email, ticket: ticket},
          actor: user
        )
        |> Ash.create()

        socket
    end
    |> assign(:form, %{"email" => ""})
    |> update_invites(socket.assigns.current_user)
    |> noreply()
  end

  defp update_invites(socket, actor) do
    TicketInvite
    |> Ash.Query.for_read(:read, %{}, actor: actor)
    |> Ash.Query.load(customer: :user)
    |> Ash.read()
    |> case do
      {:ok, list} -> socket |> assign(:invites, list)
      _ -> socket
    end
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-xl font-semibold">Ticket Invites</h1>
    <.form :let={f} for={@form} phx-submit="add_email">
      <.input field={f[:email]} label="Email" />
    </.form>

    <div :for={e <- @emails}>
      <span><%= e.email %></span>
    </div>

    <div :for={e <- @invites}>
      <span><%= e.id %></span>
      <span><%= e.receipient_email || e.customer.user.email %></span>
      <span><%= e.state %></span>
    </div>
    """
  end
end
