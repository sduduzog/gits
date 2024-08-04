defmodule GitsWeb.DashboardLive.Events do
  use GitsWeb, :live_view
  require Ash.Query

  alias Gits.Dashboard.Account
  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()
      |> Enum.map(fn item -> %{id: item.id, name: item.name} end)

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    events =
      Event
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(account.id == ^account.id)
      |> Ash.read!()

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Events")
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account_id, account.id)
      |> assign(:account_name, account.name)
      |> assign(:events, events)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end
end
