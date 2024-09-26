defmodule GitsWeb.AccountLive.SetupWizard do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  def handle_event("stuff", _unsigned_params, socket) do
    {:noreply, socket |> push_navigate(to: "/h/test/dashboard")}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto grid max-w-screen-md gap-10 bg-white p-4 lg:py-10">
      <div class="space-y-10 pt-10">
        <h1 class="text-4xl font-medium">Let's setup your host account</h1>
        <div class="grid gap-8">
          <label for="" class="grid gap-1">
            <span class="text-sm font-medium text-zinc-600">Host name</span>
            <input type="text" class="w-full rounded-lg px-4 py-3 text-sm" />
          </label>

          <label for="" class="grid gap-1">
            <span class="text-sm font-medium text-zinc-600">Handle</span>
            <div class="flex items-center rounded-lg border border-zinc-400 pl-4">
              <span class="text-sm text-zinc-500">gits.co.za/h/</span>
              <input
                type="text"
                class="w-full rounded-lg border-none py-3 pr-4 pl-0 text-sm focus-visible:ring-0"
              />
            </div>
          </label>
        </div>
      </div>

      <div class="flex items-center justify-between gap-4">
        <.link
          navigate={~p"/"}
          class="px-2 font-medium hover:bg-zinc-50 rounded-lg text-zinc-900 py-1 text-sm"
        >
          Cancel
        </.link>

        <button
          class="min-w-40 flex justify-center gap-2 rounded-lg bg-zinc-900 px-4 py-3 font-medium text-zinc-50"
          phx-click="stuff"
        >
          <span class="text-sm">Continue</span>
          <.icon name="hero-arrow-right-mini" />
        </button>
      </div>
    </div>
    """
  end
end
