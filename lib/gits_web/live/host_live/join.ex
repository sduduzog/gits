defmodule GitsWeb.HostLive.Join do
  require Ash.Query
  alias Gits.Accounts.HostInvite

  import GitsWeb.HostComponents
  use GitsWeb, :live_view

  on_mount {GitsWeb.LiveUserAuth, :live_user_required}

  def mount(params, _, socket) do
    Ash.Query.filter(HostInvite, id == ^params["invite"])
    |> Ash.Query.load([:host_name])
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, %HostInvite{} = invite} ->
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
    |> HostInvite.accept(actor: socket.assigns.current_user)
    |> IO.inspect()

    socket |> noreply()
  end
end
