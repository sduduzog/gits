defmodule GitsWeb.HostLive.EventList do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> ok()
  end

  def render(assigns) do
    ~H"""
    <!-- <div class="border p-4"></div> -->
    <div class="p-2 lg:p-4">
      <div class="flex items-start pt-5">
        <button
          phx-click={JS.navigate(~p"/hosts/test/create-event")}
          class="h-9 rounded-lg bg-zinc-950 px-4 py-2 text-zinc-50 hover:bg-zinc-800"
        >
          <span class="text-sm font-medium">Create Event</span>
        </button>
      </div>
    </div>
    """
  end
end
