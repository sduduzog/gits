defmodule GitsWeb.DashboardLive.Home do
  use GitsWeb, :live_view

  alias Gits.Dashboard.Account

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()
      |> Enum.map(fn item -> %{id: item.id, name: item.name} end)

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Overview")
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account_name, account.name)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end
end
