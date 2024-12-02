defmodule GitsWeb.HostLive.Dashboard do
  use GitsWeb, :live_view

  require Ash.Query

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Dashboard")
    |> ok(:host)
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center gap-2 p-2 lg:px-0">
      <div class="flex w-full grow items-center gap-1 text-sm">
        <div class="flex h-9 max-w-48 items-center gap-2 rounded-lg px-1 py-0.5 hover:bg-zinc-100">
          <div class="flex size-8 shrink-0 items-center justify-center rounded-full bg-zinc-500">
            <span class="font-medium text-white ">
              <%= @host.name
              |> String.split()
              |> Enum.map(&String.first(&1))
              |> Enum.join()
              |> String.upcase() %>
            </span>
          </div>
          <span class="hidden truncate font-semibold lg:inline"><%= @host.name %></span>
          <.icon name="i-lucide-chevrons-up-down" class="size-4 shrink-0 text-zinc-400" />
        </div>
        <span class="text-xs font-semibold text-zinc-400">/</span>
        <div class="flex h-9 shrink-0 items-center truncate rounded-lg px-1 text-sm font-medium">
          <span class="">Dashboard</span>
        </div>
      </div>
    </div>

    <h1 class="p-2 text-xl font-semibold">Welcome back</h1>
    """
  end
end
