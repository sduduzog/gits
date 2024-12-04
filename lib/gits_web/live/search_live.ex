defmodule GitsWeb.SearchLive do
  use GitsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-2 mx-auto grid mx-auto max-w-screen-xl">
      <div class="py-6 lg:col-span-2">
        <span class="italic text-zinc-500 text-sm">Nothing to see here</span>
      </div>
    </div>
    """
  end
end
