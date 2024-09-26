defmodule GitsWeb.HostLive.Dashboard do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto grid max-w-screen-xl items-start gap-10 lg:grid-cols-12">
      <h1 class="col-span-full pt-5 text-2xl font-semibold">Dashboard</h1>
      <div class="grid gap-4 lg:col-span-full lg:grid-cols-4">
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

      <div class="grid gap-4 lg:col-span-4">
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

      <div class="grid gap-4 lg:col-span-8">
        <h2 class="col-span-full text-xl font-semibold">Next Event</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>

      <div class="grid gap-4 lg:col-span-8">
        <h2 class="col-span-full text-xl font-semibold">Latest Reviews</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>

      <div class="grid gap-4 lg:col-span-4">
        <h2 class="col-span-full text-xl font-semibold">Average Rating</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>
    </div>
    """
  end
end
