defmodule GitsWeb.AccountLive.SetupWizard do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  def render(assigns) do
    ~H"""
    <div class="h-dvh grid-rows-[auto_1fr_auto] mx-auto grid max-w-screen-md p-4 lg:py-10">
      <div class="">
        <h2 class="sr-only">Steps</h2>
        <div>
          <p class="text-xs font-medium text-gray-500">1/0 - Create an account</p>
          <div class="mt-4 overflow-hidden rounded-full bg-zinc-200">
            <div class="h-2 w-4/5 rounded-full bg-zinc-600"></div>
          </div>
        </div>
      </div>
      <div class="grid pt-10">
        <h1 class="text-4xl font-medium">Hello there</h1>
      </div>
      <div class="flex items-center gap-4">
        <.link
          navigate={~p"/"}
          class="px-2 font-medium hover:bg-zinc-50 rounded-lg text-zinc-900 py-1 text-sm"
          onclick="history.back()"
        >
          Cancel
        </.link>
        <div role="none" class="grow"></div>
        <button class="flex gap-2 rounded-lg bg-zinc-100 px-4 py-3 font-medium text-zinc-900">
          <span class="text-sm">Back</span>
        </button>

        <button class="flex gap-2 rounded-lg bg-zinc-900 px-4 py-3 font-medium text-zinc-50">
          <span class="text-sm">Continue</span>
          <.icon name="hero-arrow-right-mini" />
        </button>
      </div>
    </div>
    """
  end
end
