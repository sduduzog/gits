defmodule GitsWeb.HostLive.Onboarding do
  use GitsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="">
      <h1 class="text-2xl font-semibold">Let's start with some basics</h1>
      <div>
        <label class="col-span-full grid gap-1 mt-8">
          <span class="text-sm font-medium">Host name</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>
      </div>
    </div>
    <div
      :if={false}
      class="h-dvh grid grid-rows-[auto_1fr_auto_auto] lg:grid-cols-[theme(space.72)_1fr]"
    >
      <div class="flex p-2 justify-end col-span-full">
        <button class="size-9 rounded-lg shrink-0">
          <.icon name="hero-x-mark" />
        </button>
      </div>
      <div class=""></div>
      <div class="lg:row-start-2"></div>
      <div class="col-span-full"></div>
    </div>
    """
  end

  def mount(params, session, socket) do
    socket
    |> assign(:page_title, "Create your host account")
    |> ok(:host_panel)
  end
end
