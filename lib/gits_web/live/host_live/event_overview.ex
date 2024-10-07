defmodule GitsWeb.HostLive.EventOverview do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> assign(:page_title, "The Ultimate Cheese Festival") |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="flex p-2 lg:p-4 gap-8">
      <span
        :for={i <- ["Attendees"]}
        class="text-sm text-zinc-400 first:text-zinc-950 rounded-lg first:font-medium"
      >
        <%= i %>
      </span>
    </div>

    <div></div>
    """
  end
end
