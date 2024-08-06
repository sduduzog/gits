defmodule GitsWeb.DashboardLive.Team do
  use GitsWeb, :dashboard_live_view

  alias Gits.Dashboard.{Invite, Member}

  def handle_params(_unsigned_params, _uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          invites: Invite |> Ash.Query.filter(state == :sent),
          members: [:actor?, :display_name, :email]
        ],
        actor: user
      )

    socket
    |> assign(:invites, account.invites)
    |> assign(:members, account.members)
    |> noreply()
  end

  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", _unsigned_params, socket) do
    slug = socket.assigns.slug
    {:noreply, redirect(socket, to: ~p"/accounts/#{slug}/team")}
  end

  def handle_event("resend_invite", unsigned_params, socket) do
    socket.assigns.invites
    |> Enum.find(fn item ->
      item.id ==
        unsigned_params["id"]
    end)
    |> Ash.Changeset.for_update(:resend, %{}, actor: socket.assigns.current_user)
    |> Ash.update!()

    {:noreply, socket}
  end

  def handle_event("cancel_invite", unsigned_params, socket) do
    socket =
      socket
      |> update(:invites, fn current_invites, %{current_user: user} ->
        current_invites
        |> Enum.find(fn item ->
          item.id ==
            unsigned_params["id"]
        end)
        |> Ash.Changeset.for_update(:cancel, %{}, actor: user)
        |> Ash.update!()

        current_invites
      end)

    {:noreply, socket}
  end
end
