defmodule GitsWeb.HostLive.EventList do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-screen-2xl">
      <div class="flex items-center pt-5">
        <h1 class="col-span-full grow text-2xl font-semibold">Events</h1>
        <button
          phx-click={JS.navigate(~p"/h/test/create-event")}
          class="h-9 rounded-lg bg-zinc-950 px-4 py-2 text-zinc-50 hover:bg-zinc-800"
        >
          <span class="text-sm font-medium">Create Event</span>
        </button>
      </div>
    </div>
    """
  end
end
