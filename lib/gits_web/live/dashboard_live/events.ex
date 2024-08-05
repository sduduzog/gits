defmodule GitsWeb.DashboardLive.Events do
  use GitsWeb, :live_view
  require Ash.Query

  alias Gits.Dashboard.Account
  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(members.user.id == ^user.id)
      |> Ash.read!()

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
