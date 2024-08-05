defmodule GitsWeb.DashboardLive.Home do
  require Ash.Query
  use GitsWeb, :live_view

  alias Gits.Dashboard.Account

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(members.user.id == ^user.id)
      |> Ash.read!()

    account =
      Enum.find(accounts, fn item -> item.id == params["slug"] end)
      |> Ash.load!([:no_event_yet, :no_payment_method])

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Overview")
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:account_name, account.name)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end
end
