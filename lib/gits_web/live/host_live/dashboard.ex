defmodule GitsWeb.HostLive.Dashboard do
  use GitsWeb, :live_view

  require Ash.Query

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Dashboard")
    |> ok(:host)
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center gap-2 p-2 lg:px-0">
      <div class="flex w-full grow items-center gap-1 text-sm">
        <div class="flex h-9 max-w-48 items-center gap-2 rounded-lg px-1 py-0.5 hover:bg-zinc-100">
          <div class="flex size-8 shrink-0 items-center justify-center rounded-full bg-zinc-500">
            <span class="font-medium text-white ">
              <%= @host.name
              |> String.split()
              |> Enum.map(&String.first(&1))
              |> Enum.join()
              |> String.upcase() %>
            </span>
          </div>
          <span :if={false} class="font-semibold hidden lg:inline truncate"><%= @host.name %></span>
          <span class="hidden truncate font-semibold lg:inline">Treehouse Inc</span>
          <.icon name="i-lucide-chevrons-up-down" class="size-4 shrink-0 text-zinc-400" />
        </div>
        <span class="text-xs font-semibold text-zinc-400">/</span>
        <div class="flex h-9 shrink-0 items-center truncate rounded-lg px-1 text-sm font-medium">
          <span class="">Dashboard</span>
        </div>
      </div>
    </div>

    <h1 class="p-2 text-xl font-semibold">Welcome back</h1>
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
                />
                <path d="m3.75 13.24l4.7-4a1.32 1.32 0 0 1 1.87.15l3.07 3.68M3.5 4.24L6.25 1.1a1 1 0 0 1 1.5 0l2.75 3.14" />
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
            phx-click={JS.navigate(~p"/hosts/#{@host.handle}/events/create-new")}
            class="h-9 gap-1 bg-zinc-950 rounded-lg inline-flex items-center text-white px-4 text-sm"
          >
            <.icon name="i-lucide-calendar-plus" />
            <span class="font-semibold">Create</span>
          </button>
        </div>
      </div>
    </div>
    """
  end
end
