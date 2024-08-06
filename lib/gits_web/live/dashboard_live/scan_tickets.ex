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
      |> assign(:payload, nil)
      |> assign(:admitted, false)

    {:ok, socket, layout: false}
  end

  def handle_event("scanned", unsigned_params, socket) do
    socket =
      ExBase58.decode(unsigned_params)
      |> case do
        {:ok, payload} ->
          socket |> assign(:payload, payload)

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event("admit", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-dvh relative w-screen">
      <%= if is_nil(@payload) do %>
        <div phx-hook="QrScanner" id="scanner" class="absolute inset-0 z-10 flex h-full"></div>
        <div class="absolute inset-0 z-20 flex h-full w-full items-center justify-center">
          <div class="size-[22rem] ring-[1000px] rounded-2xl ring-zinc-50"></div>
        </div>
      <% else %>
        <div class="absolute inset-0 flex w-full flex-col items-center justify-center gap-4 bg-zinc-50">
          <div :if={not @admitted} class="w-[22rem] grid gap-2 rounded-2xl bg-white p-2 shadow-sm">
            <div :if={false} class="rounded-md bg-red-50 p-4">
              <div class="flex">
                <div class="flex-shrink-0">
                  <.icon name="hero-x-circle-mini" class="text-red-400" />
                </div>
                <div class="ml-3">
                  <h3 class="text-sm font-medium text-red-800">
                    There were issues with this ticket
                  </h3>
                  <div class="mt-2 text-sm text-red-700">
                    <ul role="list" class="list-disc space-y-1 pl-5">
                      <li>Invalid af</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
            <div class="rounded-md bg-green-50 p-4">
              <div class="flex">
                <div class="flex-shrink-0">
                  <svg
                    class="h-5 w-5 text-green-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    aria-hidden="true"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm font-medium text-green-800">12 General tickets</p>
                </div>
              </div>
            </div>

            <div class="grid justify-center gap-4 pt-2">
              <img src="/images/placeholder.png" alt="" class="size-36 rounded-full object-cover" />
              <div class="flex flex-col items-center gap-2">
                <span class="text-center text-sm font-medium text-gray-900">Jane Cooper</span>
              </div>
            </div>
            <.simple_form
              :let={f}
              phx-submit="admit"
              for={%{}}
              class="p-2 gap-4 grid grid-cols-[4fr_1fr]"
            >
              <button class="mb-0.5 grow self-end rounded-md bg-zinc-900 p-4 text-sm font-semibold text-white">
                Admit
              </button>
              <.input type="select" field={f[:count]} options={1..12} />
            </.simple_form>
          </div>
          <div :if={@admitted} class="flex items-center gap-4">
            <div class="flex rounded-full bg-green-100 p-2 text-green-400">
              <.icon name="hero-check-circle-mini" />
            </div>
            <span class="font-medium text-green-600">12 General admissions</span>
          </div>
        </div>
      <% end %>
      <div class="absolute inset-x-0 top-0 z-30 flex p-2">
        <div class="flex w-full rounded-md bg-white p-2 shadow-sm">
          <.link
            navigate={~p"/accounts/#{@slug}/events/#{@event.id}"}
            class="rounded-xl p-2 bg-zinc-50 hover:bg-zinc-50"
          >
            <.icon name="hero-arrow-left" />
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
