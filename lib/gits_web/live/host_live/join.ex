defmodule GitsWeb.HostLive.Join do
  require Ash.Query
  alias Gits.Accounts.Invite

  import GitsWeb.HostComponents
  use GitsWeb, :live_view

  on_mount {GitsWeb.LiveUserAuth, :live_user_required}

  def mount(params, _, socket) do
    Ash.Query.filter(Invite, id == ^params["invite"])
    |> Ash.Query.load([:host_name])
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, %Invite{} = invite} ->
        socket
        |> assign(:invite, invite)
        |> GitsWeb.HostLive.assign_guest_sidebar_items()
        |> ok(:dashboard)

      _ ->
        socket
        |> ok(:not_found)
    end
  end

  def handle_event("accept_invite", _, socket) do
    socket.assigns.invite
    |> Invite.accept(actor: socket.assigns.current_user, load: :host)
    |> case do
      {:ok, invite} ->
        socket
        |> push_navigate(to: ~p"/hosts/#{invite.host.handle}/dashboard")
        |> noreply()
    end
  end
end
