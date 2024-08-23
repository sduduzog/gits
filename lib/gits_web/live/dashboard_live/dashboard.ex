defmodule GitsWeb.DashboardLive.Dashboard do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  def render(assigns) do
    ~H"""
    <div class="grid-rows-[auto_1fr] grid h-screen gap-2 bg-white pt-2 md:bg-zinc-50 md:p-2">
      <header class="flex gap-4 p-2 md:divide-x">
        <div class="relative flex shrink-0">
          <.link navigate="/" class="text-2xl font-black italic text-zinc-800">
            GiTS
          </.link>
        </div>
        <div></div>
      </header>
      <main class="bg-white p-2 md:rounded-xl md:shadow">Hello</main>
    </div>
    """
  end
end
