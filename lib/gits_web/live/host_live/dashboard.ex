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
    <div class="flex items-center gap-2 p-2">
      <div class="flex w-full grow items-center gap-1 text-sm">
        <div class="flex shrink-0 items-center truncate rounded-lg border border-transparent p-2 text-sm/5 font-semibold">
          <span class="truncate ">
            Dashboard
          </span>
        </div>
      </div>
    </div>

    <h1 class="p-2 text-xl font-semibold">Welcome back</h1>
    """
  end
end
