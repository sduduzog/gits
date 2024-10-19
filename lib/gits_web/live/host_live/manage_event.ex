defmodule GitsWeb.HostLive.ManageEvent do
  use GitsWeb, :host_live_view

  def render(assigns) do
    ~H"""
    <div class="flex items-center gap-2 p-2">
      <.link
        replace={true}
        navigate={~p"/hosts/#{@host_handle}/dashboard"}
        class="flex items-center gap-2 rounded-lg h-9 px-2"
      >
        <.icon name="hero-chevron-left" class="size-5" />
        <span class="text-sm font-medium lg:inline hidden">Back</span>
      </.link>

      <div class="flex gap-2 grow items-center border-l truncate pl-4 text-sm font-medium">
        <span class="text-zinc-500 truncate">Events</span>
        <.icon name="hero-slash-micro" class="shrink-0" />
        <span class="truncate">Create an event</span>
      </div>

      <button class="flex size-9 lg:w-auto items-center gap-2 justify-center shrink-0 rounded-lg lg:px-4">
        <.icon name="hero-megaphone" class="size-5" />
        <span class="text-sm hidden lg:inline">Help</span>
      </button>
    </div>

    <h1 class="p-2 text-2xl font-semibold">Create an event</h1>

    <div>
      create new event
    </div>
    """
  end
end
