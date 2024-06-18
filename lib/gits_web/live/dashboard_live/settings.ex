defmodule GitsWeb.DashboardLive.Settings do
  use GitsWeb, :live_view

  alias Gits.Dashboard.Account
  alias Gits.PaystackApi

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()
      |> Enum.map(fn item -> %{id: item.id, name: item.name} end)

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    banks =
      PaystackApi.list_banks!()
      |> Enum.map(fn bank -> {bank.name, bank.code} end)

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Settings")
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:account_name, account.name)
      |> assign(:banks, banks)
      |> assign(:toggle, false)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket = socket |> assign(:form, %{})
    {:noreply, socket}
  end

  def handle_event("enable_billing", _unsigned_params, socket) do
    {:noreply,
     update(socket, :account, fn current_account, %{current_user: user} ->
       current_account
       |> Ash.Changeset.for_update(:enable_billing, %{billing_settings: %{}}, actor: user)
       |> Ash.update!()
       |> Ash.load!([:billing_enabled?, billing_settings: [:paystack_ready?]], actor: user)
     end)}
  end

  def handle_event("toggle", _unsigned_params, socket) do
    {:noreply, update(socket, :toggle, fn current_toggle, _ -> !current_toggle end)}
  end

  def handle_event(_, _unsigned_params, socket) do
    {:noreply, socket}
  end
end
