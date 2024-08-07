defmodule GitsWeb.EventLive.EventComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes

  def floating_event_date(assigns) do
    ~H"""
    <div class="size-12 border-zinc-200/40 text-white/90 bg-black/20 absolute top-2 left-2 z-10 flex shrink-0 flex-col items-center justify-center rounded-xl border *:leading-4 md:top-4 md:left-4">
      <span class="text-base font-semibold"><%= @day %></span>
      <span class="text-xs"><%= @month %></span>
    </div>
    """
  end
end
