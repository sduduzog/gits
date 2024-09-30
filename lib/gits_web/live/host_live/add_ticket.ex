defmodule GitsWeb.HostLive.AddTicket do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto grid max-w-screen-sm gap-10">
      <div class="w-full truncate pt-5">
        <.link
          navigate={~p"/h/test/events/event-id"}
          class="inline-flex items-center gap-1 truncate w-full"
        >
          <.icon name="hero-chevron-left-mini" class="shrink-0" />
          <span class="text-sm font-medium text-zinc-800">
            The Ultimate Cheese Festival
          </span>
        </.link>
        <h1 class="col-span-full pt-2 text-2xl font-semibold">Add Ticket</h1>
        <span class="text-sm font-medium text-zinc-700">Main Event</span>
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

      <div class="grid grid-cols-2 gap-6">
        <label class="grid gap-1" for="">
          <span class="text-sm">Quantity</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label class="grid gap-1" for="">
          <span class="text-sm">Price</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label class="col-span-full grid gap-1" for="">
          <span class="text-sm">Ticket Type</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label class="grid gap-1" for="">
          <span class="text-sm">Start date</span>
          <input type="datetime-local" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label class="grid gap-1" for="">
          <span class="text-sm">End date</span>
          <input type="datetime-local" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label class="col-span-full grid gap-1" for="">
          <span class="text-sm">Description</span>
          <textarea
            rows="7"
            type="datetime-local"
            class="rounded-lg border-zinc-300 px-3 py-2 text-sm"
          ></textarea>
        </label>

        <div class="col-span-full flex justify-end gap-4">
          <button
            phx-click={JS.navigate(~p"/h/test/events/event-id")}
            class="h-9 rounded-lg bg-zinc-900 px-4 py-2 text-sm font-medium text-zinc-50"
          >
            <span>Create Ticket</span>
          </button>
        </div>
      </div>
    </div>
    """
  end
end
