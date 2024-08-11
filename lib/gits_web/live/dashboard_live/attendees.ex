defmodule GitsWeb.DashboardLive.Attendees do
  use GitsWeb, :dashboard_live_view

  alias Gits.Storefront.{Event, Ticket}

  def handle_params(unsigned_params, _uri, socket) do
    socket
    |> load_defalts(unsigned_params)
    |> noreply()
  end

  defp load_defalts(socket, unsigned_params) do
    %{current_user: user, account: account, slug: slug} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          events:
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(id == ^unsigned_params["event_id"])
            |> Ash.Query.load([
              :masked_id,
              :address,
              :payment_method_required?,
              tickets: Ticket |> Ash.Query.filter(test == false) |> Ash.Query.load([:total_sold])
            ])
        ],
        actor: user
      )

    [event] = account.events

    socket
    |> assign(:event, event)
    |> assign(:event_name, event.name)
    |> assign(:title, event.name)
    |> assign(:context_options, [
      %{
        label: "Scan ticket",
        to: ~p"/accounts/#{slug}/events/#{event.id}/attendees/scan",
        icon: "hero-qr-code-mini"
      },
      %{
        label: "Attendees",
        to: ~p"/accounts/#{slug}/events/#{event.id}/attendees",
        icon: "hero-users-mini"
      }
    ])
  end

  def render(%{live_action: :scan} = assigns) do
    ~H"""
    <div phx-hook="QrScanner" id="scannner-container" class="fixed inset-0 h-screen w-screen bg-white">
      <div id="scanner" class="absolute inset-0 z-10 flex h-full"></div>
      <div class="absolute inset-0 z-20 flex h-full w-full items-center justify-center">
        <div class="absolute inset-x-0 top-0 flex w-full items-center gap-2 bg-white p-2">
          <button id="rotate-camera" class="flex shrink-0 rounded-xl p-3 hover:bg-zinc-100">
            <.icon name="hero-arrow-path-rounded-square-mini" />
          </button>
          <span id="camera-label" class="grow truncate text-right text-xs text-zinc-500">Label</span>
          <button id="rotate-camera" class="flex shrink-0 rounded-xl p-3 hover:bg-zinc-100">
            <.icon name="hero-arrow-path-rounded-square-mini" />
          </button>
        </div>

        <div class="size-[22rem] ring-[1000px] rounded-2xl ring-white"></div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-xl font-semibold">Attendees</h1>
    <div>Attendees</div>
    """
  end
end
