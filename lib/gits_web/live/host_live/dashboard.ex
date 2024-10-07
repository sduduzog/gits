defmodule GitsWeb.HostLive.Dashboard do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="flex p-2 lg:p-4 gap-8">
      <span
        :for={i <- ["1 day", "3 days", "Week", "Month"]}
        class="text-sm text-zinc-400 first:text-zinc-950 rounded-lg first:font-medium"
      >
        <%= i %>
      </span>
    </div>
    <div class="lg:flex px-2 lg:px-4">
      <div class="grow grid gap-4 gap-y-10 lg:grid-cols-4">
        <div class="grid gap-1">
          <span class="text-zinc-600">Revenue</span>
          <span class="text-3xl font-medium">R 0.00</span>
        </div>

        <div class="grid gap-1">
          <span class="text-zinc-600">Unique Customers</span>
          <span class="text-3xl font-medium">0</span>
        </div>

        <div class="grid gap-1">
          <span class="text-zinc-600">Event Page Views</span>
          <span class="text-3xl font-medium">0</span>
        </div>

        <div class="grid gap-1">
          <span class="text-zinc-600">Conversion Rate</span>
          <span class="text-3xl font-medium">0%</span>
        </div>
      </div>
    </div>
    <div :if={false} class="grid items-start gap-10 lg:grid-cols-12">
      <div class="col-span-full flex flex-wrap items-end justify-between gap-4 rounded-3xl border p-4 lg:col-span-8 lg:p-8">
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
            phx-click={JS.navigate(~p"/hosts/test/events/new")}
            class="inline-flex rounded-lg bg-zinc-950 px-4 py-2 text-zinc-50"
          >
            <span class="text-sm font-medium">Create event</span>
          </button>
        </div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-full lg:grid-cols-4">
        <h2 class="col-span-full text-xl font-semibold">Ticket Sales</h2>
        <div class="grid gap-2 rounded-xl border p-4">
          <h3 class="text-sm font-semibold">Generated Revenue</h3>
          <span class="text-4xl font-medium">R 0.00</span>
        </div>
        <div class="grid gap-2 rounded-xl border p-4">
          <h3 class="text-sm font-semibold">Tickets Sold</h3>
          <span class="text-4xl font-medium">0</span>
        </div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-4">
        <h2 class="col-span-full text-xl font-semibold">Upcoming Events</h2>
        <div class="grid gap-2 rounded-xl border p-4">
          <div :for={_ <- []} class="flex w-full items-center gap-2 truncate">
            <span class="shrink-0 rounded-md border-2 border-zinc-400 p-1 px-2 font-semibold uppercase">
              Sep 12
            </span>
            <h3 class="grow truncate text-sm font-semibold">
              The Ultimate Cheese Festival The Ultimate Cheese Festival
            </h3>
            <button class="flex rounded-lg p-2">
              <.icon name="hero-ellipsis-vertical-mini" />
            </button>
          </div>
        </div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-8">
        <h2 class="col-span-full text-xl font-semibold">Next Event</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-8">
        <h2 class="col-span-full text-xl font-semibold">Latest Reviews</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-4">
        <h2 class="col-span-full text-xl font-semibold">Average Rating</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>
    </div>
    """
  end
end
