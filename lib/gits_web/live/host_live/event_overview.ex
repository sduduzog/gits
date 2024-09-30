defmodule GitsWeb.HostLive.EventOverview do
  use GitsWeb, :host_live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto grid max-w-screen-lg gap-10">
      <div class="w-full truncate pt-5">
        <.link navigate={~p"/h/test/events"} class="inline-flex items-center gap-1 truncate w-full">
          <.icon name="hero-chevron-left-mini" class="shrink-0" />
          <span class="text-sm font-medium text-zinc-800">Events</span>
        </.link>
        <div class="grid gap-2 pt-2 lg:flex">
          <div class="grid grow items-start gap-2 lg:flex">
            <div class="aspect-[3/2] w-32 bg-zinc-200"></div>
            <div class="grid gap-1">
              <h1 class="col-span-full text-2xl font-semibold">The Ultimate Cheese Festival</h1>
              <div class="flex flex-wrap gap-x-4 gap-y-2">
                <div :if={false} class="flex items-center gap-2 text-zinc-500">
                  <.icon name="hero-calendar-days-mini" />
                  <span class="text-sm">24 Aug 2024 at 8 PM</span>
                </div>
                <div :if={false} class="flex items-center gap-2 text-zinc-500">
                  <.icon name="hero-map-mini" />
                  <span class="text-sm">Artistry JHB, Sandton</span>
                </div>
              </div>
            </div>
          </div>
          <div class="">
            <button class="rounded-lg bg-zinc-50 px-4 py-3 text-sm font-medium">Edit</button>
          </div>
        </div>
      </div>

      <div :if={false} class="col-span-full rounded-md bg-blue-50 p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <.icon name="hero-information-circle-mini" class="text-blue-400" />
          </div>
          <div class="ml-3 flex-1 md:flex md:justify-between">
            <p class="text-sm text-blue-700">
              A new software update is available. See what’s new in version 2.0.4.
            </p>
            <p :if={false} class="mt-3 text-sm md:mt-0 md:ml-6">
              <a href="#" class="whitespace-nowrap font-medium text-blue-700 hover:text-blue-600">
                Details <span aria-hidden="true"> &rarr;</span>
              </a>
            </p>
          </div>
        </div>
      </div>

      <div class="grid gap-8 lg:grid-cols-2">
        <div class="max-w-96 col-span-full flex py-2">
          <span :for={i <- ["Sessions"]}><%= i %></span>
        </div>

        <div class="col-span-full flex justify-between">
          <h2 class="text-xl">Sessions</h2>
          <.link
            navigate={~p"/h/test/events/event-id/sessions/add"}
            class="text-sm font-medium underline"
          >
            Add Session
          </.link>
        </div>

        <div class="grid gap-8 rounded-xl border p-4">
          <div class="flex items-center gap-2">
            <div class="grid grow">
              <span class="text-sm font-medium text-zinc-800">Main event</span>
              <span class="text-sm text-zinc-500">20 Aug 2024, 12:00 - 14:30, 24 Aug 2024</span>
            </div>
            <button class="size-9 inline-flex items-center justify-center rounded-lg">
              <.icon name="hero-ellipsis-vertical-mini" />
            </button>
          </div>
          <div class="flex items-center">
            <div class="grow">
              <span class="text-lg font-medium text-zinc-500">Tickets</span>
            </div>
            <button class="flex h-9 items-center rounded-lg border border-zinc-300 px-4 py-2">
              <span class="text-sm font-medium">Add Ticket</span>
            </button>
          </div>
          <div class="grid gap-2 divide-y">
            <div :for={i <- ["Early Access", "General"]} class="grid py-2">
              <div class="flex items-center gap-4">
                <span class="grow text-base"><%= i %></span>
                <span class="text-sm text-zinc-600">R 100.00</span>
                <button class="size-9 inline-flex items-center justify-center rounded-lg p-2">
                  <.icon name="hero-pencil-square-mini" />
                </button>

                <button class="size-9 inline-flex items-center justify-center rounded-lg p-2">
                  <.icon name="hero-trash-mini" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
