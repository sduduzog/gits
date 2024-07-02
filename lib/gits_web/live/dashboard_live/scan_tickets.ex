defmodule GitsWeb.DashboardLive.ScanTickets do
  use GitsWeb, :live_view

  require Ash.Query

  alias Gits.Dashboard.Account
  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:read)
      |> Ash.read!(actor: user)

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    event =
      Event
      |> Ash.Query.for_read(:read, %{id: params["event_id"]}, actor: user)
      |> Ash.Query.load([:tickets, :account])
      |> Ash.read_one!()

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:event, event)

    {:ok, socket, layout: false}
  end

  def handle_event("scanned", unsigned_params, socket) do
    IO.inspect(unsigned_params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-dvh w-dvh relative">
      <div phx-hook="QrScanner" id="scanner" class="absolute inset-0 z-10 flex h-full"></div>
      <div class="absolute inset-0 z-20 flex h-full w-full items-center justify-center">
        <div class="size-[22rem] ring-[1000px] rounded-2xl ring-zinc-50"></div>
      </div>
      <div class="w-[22rem] absolute bottom-4 left-1/2 z-30 flex -translate-x-1/2 rounded-2xl bg-white p-2 shadow-sm">
        <.link
          navigate={~p"/accounts/#{@slug}/events/#{@event.id}"}
          class="rounded-xl p-2 hover:bg-zinc-50"
        >
          <.icon name="hero-arrow-left" />
        </.link>
      </div>
    </div>
    """
  end
end
