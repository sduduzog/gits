defmodule GitsWeb.HostLive.Team do
  require Ash.Query
  alias Gits.Accounts.User
  alias Gits.Accounts.Host
  import GitsWeb.HostComponents
  use GitsWeb, :live_view

  def mount(%{"handle" => handle}, _, socket) do
    user = socket.assigns.current_user

    Ash.load(
      user,
      [
        hosts: Ash.Query.filter(Host, handle == ^handle) |> Ash.Query.load(roles: :user)
      ],
      actor: user
    )
    |> case do
      {:ok, %User{hosts: [%Host{} = host]}} ->
        socket
        |> GitsWeb.HostLive.assign_sidebar_items(__MODULE__, host)
        |> assign(:page_title, "Team")
        |> assign(:host, host)
        |> assign(:roles, host.roles)
        |> ok(:dashboard)

      _ ->
        socket |> ok(:not_found)
    end
  end
end
