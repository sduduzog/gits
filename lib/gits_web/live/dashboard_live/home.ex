defmodule GitsWeb.DashboardLive.Home do
  use GitsWeb, :dashboard_live_view

  alias Gits.Dashboard.Account

  # def mount(params, _session, socket) do
  #   user = socket.assigns.current_user
  #
  #   accounts =
  #     Account
  #     |> Ash.Query.for_read(:read, %{}, actor: user)
  #     |> Ash.Query.filter(members.user.id == ^user.id)
  #     |> Ash.read!()
  #
  #   account =
  #     Enum.find(accounts, fn item -> item.id == params["slug"] end)
  #     |> Ash.load!([:no_event_yet, :no_invites_yet, :no_payment_method])
  #
  #   socket =
  #     socket
  #     |> assign(:slug, params["slug"])
  #     |> assign(:title, "Overview")
  #     |> assign(:context_options, nil)
  #     |> assign(:accounts, accounts)
  #     |> assign(:account, account)
  #     |> assign(:account_name, account.name)
  #
  #   {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  # end

  def handle_params(_unsigned_params, uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!([:no_event_yet, :no_invites_yet, :no_payment_method], actor: user)

    socket
    |> assign(:account, account)
    |> noreply()
  end
end
