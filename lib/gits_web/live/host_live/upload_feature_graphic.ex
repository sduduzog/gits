defmodule GitsWeb.HostLive.UploadFeatureGraphic do
  use GitsWeb, :host_live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto grid max-w-screen-lg gap-10">
      <div class="w-full truncate pt-5">
        <.link
          navigate={~p"/h/test/events/event-id"}
          class="inline-flex items-center gap-1 truncate w-full"
        >
          <.icon name="hero-chevron-left-mini" class="shrink-0" />
          <span class="text-sm font-medium text-zinc-800">Events</span>
          <span class="text-sm font-medium text-zinc-800">/</span>
          <span class="truncate text-sm text-zinc-600">
            The Ultimate Cheese Festival The Ultimate Cheese Festival
          </span>
        </.link>
        <h1 class="col-span-full pt-2 text-2xl font-semibold">Upload Feature Graphic</h1>
      </div>

      <div class="flex flex-wrap gap-6">
        <div class="aspect-[3/2] w-full bg-zinc-200 lg:max-w-80"></div>
        <div class="grow">
          <div class="flex justify-between">
            <button class="rounded-lg bg-zinc-900 px-4 py-3 text-zinc-50" phx-click="continue">
              <span class="text-sm font-medium">Upload</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
