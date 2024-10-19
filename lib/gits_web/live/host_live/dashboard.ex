defmodule GitsWeb.HostLive.Dashboard do
  alias Gits.Hosts.Host
  use GitsWeb, :host_live_view

  require Ash.Query

  def mount(params, _session, socket) do
    host =
      Host
      |> Ash.Query.filter(handle == ^params["handle"])
      |> Ash.read_first!()
      |> IO.inspect()

    socket
    |> assign(:host_handle, host.handle)
    |> assign(:host_name, host.name)
    |> assign(:host_logo, host.logo)
    |> assign(:page_title, "The Ultimate Cheese Festival")
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="p-2 flex items-center">
      <div class="grow flex items-center text-sm"></div>

      <button class="flex gap-2 items-center h-9 px-4 rounded-lg">
        <.icon name="hero-megaphone" class="size-5" />
        <span class="text-sm">Help</span>
      </button>
    </div>
    <h1 class="p-2 text-2xl font-semibold">Welcome back</h1>
    <div class="grid items-start gap-10 lg:grid-cols-12 p-2">
      <div class="col-span-full flex flex-wrap items-end justify-between gap-4 rounded-3xl border p-4 lg:p-8">
        <div class="flex flex-col items-start gap-4">
          <div class="bg-zinc-500/5 relative inline-flex rounded-full border border-zinc-200 p-8">
            <div class="bg-zinc-500/5 absolute bottom-0 left-28 h-10 w-40 rounded-full border border-zinc-200">
            </div>
            <svg xmlns="http://www.w3.org/2000/svg" class="size-20 text-zinc-300" viewBox="0 0 14 14">
              <g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
                <rect width="13" height="9" x=".5" y="4.24" rx=".5" /><circle
                  cx="4.25"
                  cy="7.99"
                  r="1.25"
                /><path d="m3.75 13.24l4.7-4a1.32 1.32 0 0 1 1.87.15l3.07 3.68M3.5 4.24L6.25 1.1a1 1 0 0 1 1.5 0l2.75 3.14" />
              </g>
            </svg>
          </div>

          <h1 class="text-5xl font-medium">Create your first event</h1>
          <p class="text-zinc-500 lg:max-w-96">
            Start by adding the details of your event and reach your audience in no time!
          </p>
        </div>
        <div>
          <button
            phx-click={JS.navigate(~p"/hosts/#{@host_handle}/events/new")}
            class="inline-flex rounded-lg bg-zinc-950 px-4 py-2 text-zinc-50"
          >
            <span class="text-sm font-semibold">Create event</span>
          </button>
        </div>
      </div>
    </div>
    """
  end
end
