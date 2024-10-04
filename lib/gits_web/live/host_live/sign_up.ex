defmodule GitsWeb.HostLive.SignUp do
  use GitsWeb, :host_live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto grid max-w-screen-sm gap-10">
      <div class="space-y-8 pt-10">
        <h1 class="col-span-full grow text-2xl font-semibold">
          Let's setup your host account
        </h1>
        <div class="grid gap-4">
          <label for="" class="grid gap-1">
            <span class="text-sm font-medium text-zinc-600">Host name</span>
            <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
          </label>

          <label for="" class="grid gap-1">
            <div class="flex items-center rounded-lg border border-zinc-300 pl-3">
              <span class="text-sm text-zinc-400">gits.co.za/hosts/</span>
              <input
                type="text"
                class="w-full rounded-lg border-none py-2 pr-3 pl-0 text-sm focus-visible:ring-0"
              />
            </div>
          </label>
        </div>
      </div>

      <div class="flex items-center justify-end gap-4">
        <button
          class="flex justify-center gap-2 rounded-lg bg-zinc-900 px-4 py-2 font-medium text-zinc-50"
          phx-click="continue"
        >
          <span class="text-sm">Continue</span>
          <.icon name="hero-arrow-right-mini" />
        </button>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:title, "Become a host")
    |> ok(:host_panel)
  end

  def handle_event("close", _, socket) do
    socket
    |> push_navigate(to: ~p"/host-with-us", replace: true)
    |> noreply()
  end

  def handle_event("continue", _, socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/create-event", replace: true)
    |> noreply()
  end
end
