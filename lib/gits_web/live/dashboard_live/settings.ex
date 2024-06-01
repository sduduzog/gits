defmodule GitsWeb.DashboardLive.Settings do
  use GitsWeb, :live_view

  alias Gits.Dashboard.Account

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    account =
      Account
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.load(:billing_enabled?)
      |> Ash.read_one!()

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Settings")
      |> assign(:account, account)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next}}
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
       |> Ash.load!(:billing_enabled?, actor: user)
     end)}
  end
end
