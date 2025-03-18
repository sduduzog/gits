defmodule GitsWeb.HostLive.Join do
  require Ash.Query
  alias Gits.Accounts.HostInvite
  alias Gits.Accounts.Host

  import GitsWeb.HostComponents
  use GitsWeb, :live_view

  on_mount {GitsWeb.LiveUserAuth, :live_user_required}

  def mount(params, _, socket) do
    Ash.Query.filter(Host, handle == ^params["handle"])
    |> Ash.Query.load(invites: Ash.Query.filter(HostInvite, id == ^params["invite"]))
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, %Host{} = host} ->
        [invite] = host.invites

        socket
        |> assign(:host, host)
        |> assign(:invite, invite)
        |> GitsWeb.HostLive.assign_guest_sidebar_items(__MODULE__, host)
        |> ok(:dashboard)
    end
  end

  def handle_event("accept_invite", _, socket) do
    socket |> noreply()
  end
end
