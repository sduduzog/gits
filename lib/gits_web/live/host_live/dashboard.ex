defmodule GitsWeb.HostLive.Dashboard do
  alias Gits.Accounts.User
  alias Gits.Storefront.Order
  alias Gits.Accounts.Host
  use GitsWeb, :live_view

  require Ash.Query

  def mount(%{"handle" => handle}, _, socket) do
    user = socket.assigns.current_user

    Ash.load(
      user,
      [
        hosts:
          Ash.Query.filter(Host, handle == ^handle)
          |> Ash.Query.load(:total_events)
      ],
      actor: user
    )
    |> case do
      {:ok, %User{hosts: [%Host{} = host]}} ->
        socket
        |> assign(:host, host)
        |> assign(:page_title, "Dashboard")
        |> ok(:host)
    end
  end
end
