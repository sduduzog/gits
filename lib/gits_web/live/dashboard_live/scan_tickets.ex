defmodule GitsWeb.DashboardLive.ScanTickets do
  use GitsWeb, :live_view

  require Ash.Query

  alias Gits.Dashboard.Account

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:read)
      |> Ash.read!(actor: user)

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:account_name, account.name)

    {:ok, socket, layout: false}
  end

  def handle_event("scanned", unsigned_params, socket) do
    IO.inspect(unsigned_params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div phx-hook="QrScanner" id="scanner" class="h-dvh flex"></div>
    <div class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="size-80 ring-[1000px] rounded-2xl ring-zinc-50"></div>
    </div>
    """
  end
end
