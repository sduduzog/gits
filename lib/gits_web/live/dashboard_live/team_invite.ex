defmodule GitsWeb.DashboardLive.TeamInvite do
  alias Gits.Dashboard.Member
  use GitsWeb, :live_view

  alias Gits.Dashboard.Invite

  def mount(params, _session, socket) do
    user =
      socket.assigns.current_user

    invite =
      Invite
      |> Ash.Query.for_read(:read_for_recipient, %{id: params["invite_id"]}, actor: user)
      |> Ash.read_one!()

    if is_nil(invite) do
      raise GitsWeb.Exceptions.NotFound, "no invite for user"
    end

    socket = socket |> assign(:invite, invite)

    {:ok, socket}
  end

  def handle_event("accept_invite", _unsigned_params, socket) do
    invite = socket.assigns.invite
    user = socket.assigns.current_user

    Member
    |> Ash.Changeset.for_create(
      :accept_invitation,
      %{invite: invite, user: user, account: invite.account},
      actor: user
    )
    |> Ash.create!()

    {:noreply, push_navigate(socket, to: ~p"/accounts/#{invite.account.id}")}
  end

  def render(assigns) do
    ~H"""
    <h1 class="px-4 text-3xl">You have been invited to join <%= @invite.account.name %></h1>
    <div class="flex w-full flex-wrap items-start gap-8 px-4 *:flex *:flex-col">
      <button
        class="rounded-lg bg-zinc-700 p-3 px-4 text-sm font-medium text-white"
        phx-click="accept_invite"
      >
        Accept Invitation
      </button>
    </div>
    """
  end
end
