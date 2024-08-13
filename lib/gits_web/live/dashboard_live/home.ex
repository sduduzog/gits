defmodule GitsWeb.DashboardLive.Home do
  use GitsWeb, :dashboard_live_view

  def handle_params(_unsigned_params, _uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!([:no_event_yet, :no_invites_yet, :no_payment_method], actor: user)

    socket
    |> assign(:account, account)
    |> noreply()
  end
end
