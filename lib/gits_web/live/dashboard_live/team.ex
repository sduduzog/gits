defmodule GitsWeb.DashboardLive.Team do
  use GitsWeb, :live_view

  alias Gits.Dashboard.Account
  alias Gits.Dashboard.Invite
  alias Gits.Dashboard.Member

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()
      |> Enum.map(fn item -> %{id: item.id, name: item.name} end)

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    members =
      Member
      |> Ash.Query.for_read(:read_for_dashboard, %{}, actor: user)
      |> Ash.read!()

    invites =
      Invite
      |> Ash.Query.for_read(:read_for_dashboard, %{}, actor: user)
      |> Ash.read!()

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Team")
      |> assign(:context_options, nil)
      |> assign(:action, params["action"])
      |> assign(:accounts, accounts)
      |> assign(:account_name, account.name)
      |> assign(:members, members)
      |> assign(:invites, invites)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
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
