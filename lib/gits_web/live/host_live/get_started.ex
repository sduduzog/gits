defmodule GitsWeb.HostLive.GetStarted do
  use GitsWeb, :host_live_view

  def mount(params, session, socket) do
    socket |> assign(:page_title, "Get started") |> ok(:host_panel)
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-xl">
      <h1 class="text-2xl font-semibold">Create a host account</h1>
      <p class="mt-2 text-sm text-gray-700">
        A list of all the attendees who have been checked in for this event.
      </p>
    </div>
    <div class="grid grid-cols-2 gap-6 mx-auto pt-4 max-w-xl">
      <div class="col-span-full space-y-2">
        <label class="col-span-full grid gap-1">
          <span class="text-sm font-medium">Host name</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label class="col-span-full grid gap-1">
          <div class="flex items-center rounded-lg border border-zinc-300 pl-3">
            <span class="text-sm text-zinc-500">gits.co.za/hosts/</span>
            <input
              type="text"
              value="This is a very long value placeholder"
              class="w-full rounded-lg border-none py-2 pl-0 pr-3 text-sm focus-visible:ring-0"
            />
            <.icon :if={false} name="hero-check-micro" class="shrink-0 mr-3" />
            <.icon name="hero-arrow-path-micro" class="shrink-0 animate-spin text-zinc-400 mr-3" />
          </div>
        </label>
      </div>

      <div class="col-span-full grid grid-cols-[auto_1fr] items-center gap-1 gap-x-4">
        <span class="col-span-full w-full text-sm font-medium">Upload the host logo</span>
        <div class="aspect-square w-24 rounded-xl bg-zinc-200"></div>
        <div class="inline-grid">
          <label class="inline-flex">
            <span class="sr-only">Choose logo</span>
            <input
              type="file"
              class="w-full text-sm font-medium file:mr-4 file:h-9 file:rounded-lg file:border file:border-solid file:border-zinc-300 file:bg-white file:px-4 file:py-2 hover:file:bg-zinc-50"
            />
          </label>
        </div>
      </div>
    </div>
    """
  end
end
