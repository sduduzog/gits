defmodule GitsWeb.HostLive.Dashboard do
  alias Gits.Storefront.Event
  alias Gits.Accounts.User
  alias Gits.Accounts.Host
  import GitsWeb.HostComponents
  use GitsWeb, :live_view

  require Ash.Query

  def mount(%{"handle" => handle}, _, socket) do
    user = socket.assigns.current_user

    Ash.load(
      user,
      [
        hosts:
          Ash.Query.filter(Host, handle == ^handle)
          |> Ash.Query.load([
            :total_events,
            upcoming_events:
              Ash.Query.sort(Event, [:starts_at, :ends_at])
              |> Ash.Query.load([:currently_happening?, poster: [:url]])
          ])
      ],
      actor: user
    )
    |> case do
      {:ok, %User{hosts: [%Host{} = host]}} ->
        socket
        |> GitsWeb.HostLive.assign_sidebar_items(__MODULE__, host)
        |> assign(:page_title, "Home")
        |> assign(:host, host)
        |> ok(:dashboard)

      _ ->
        socket |> ok(:not_found)
    end
  end
end
