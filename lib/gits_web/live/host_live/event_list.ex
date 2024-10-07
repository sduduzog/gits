defmodule GitsWeb.HostLive.EventList do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-end">
      <div class="flex grow gap-8">
        <span
          :for={i <- ["All", "Drafts", "Published"]}
          class="text-sm text-zinc-400 first:text-zinc-950 rounded-lg first:font-medium"
        >
          <%= i %>
        </span>
      </div>
      <button
        phx-click={JS.navigate(~p"/hosts/test/events/new")}
        class="h-9 rounded-lg bg-zinc-950 inline-flex items-center gap-2 px-4 py-2 text-zinc-50 hover:bg-zinc-800"
      >
        <.icon name="hero-plus-mini" />
        <span class="text-sm font-medium">New event</span>
      </button>
    </div>
    <div class="divide-y divide-zinc-100">
      <div :for={_ <- 1..3} class="py-4 flex gap-4 items-center">
        <div class="aspect-[3/2] h-20 bg-zinc-200 rounded-xl"></div>
        <div class="grid w-full gap-1.5 grow">
          <h2 class="font-semibold truncate">
            <.link navigate={~p"/hosts/test/events/event_id"}>The Ultimate Cheese Festival</.link>
          </h2>
          <span class="text-sm text-zinc-500">5 Nov 2024, at 4:30 PM</span>
          <span class="text-sm text-zinc-500">5/40 tickets sold</span>
        </div>
        <div class="">
          <button class="size-9 inline-flex items-center justify-center">
            <.icon name="hero-ellipsis-vertical-mini" />
          </button>
        </div>
      </div>
    </div>
    """
  end
end
