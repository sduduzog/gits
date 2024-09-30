defmodule GitsWeb.HostLive.Dashboard do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto grid max-w-screen-xl items-start gap-10 lg:grid-cols-12">
      <h1 class="col-span-full pt-5 text-2xl font-semibold">Dashboard</h1>

      <div class="col-span-full rounded-md bg-blue-50 p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <.icon name="hero-information-circle-mini" class="text-blue-400" />
          </div>
          <div class="ml-3 flex-1 md:flex md:justify-between">
            <p class="text-sm text-blue-700">
              Create your first event. We'll guide you through the whole experience.
            </p>
            <p class="mt-3 text-sm md:mt-0 md:ml-6">
              <.link
                navigate={~p"/h/test/create-event"}
                class="whitespace-nowrap font-medium text-blue-700 hover:text-blue-600"
              >
                Create first event <span aria-hidden="true"> &rarr;</span>
              </.link>
            </p>
          </div>
        </div>
      </div>

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
