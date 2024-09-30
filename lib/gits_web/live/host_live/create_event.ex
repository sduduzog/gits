defmodule GitsWeb.HostLive.CreateEvent do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto grid max-w-screen-md gap-10">
      <h1 class="col-span-full pt-5 text-2xl font-semibold">Create Event</h1>

      <div class="grid grid-cols-2 gap-4">
        <label for="" class="col-span-full grid gap-1">
          <span class="text-sm">Name</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label for="" class="grid gap-1">
          <span class="text-sm">Start date</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label for="" class="grid gap-1">
          <span class="text-sm">End date</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label for="" class="col-span-full grid gap-1">
          <span class="text-sm">Description</span>
          <textarea rows="5" type="text" class="rounded-lg border-zinc-300 px-3 py-2 text-sm"></textarea>
        </label>

        <div class="col-span-full flex justify-between">
          <button class="rounded-lg bg-zinc-50 px-4 py-2" onclick="history.back()">
            <span class="text-sm font-medium">Cancel</span>
          </button>

          <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
            <span class="text-sm font-medium">Continue</span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("continue", _unsigned_params, socket) do
    {:noreply, socket |> push_navigate(to: ~p"/h/test/events/event-id/upload-feature-graphic")}
  end
end
