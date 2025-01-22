defmodule GitsWeb.HostLive.Settings.Index do
  use GitsWeb, :live_component

  import GitsWeb.HostComponents

  def render(assigns) do
    ~H"""
    <div>
      <.host_header current_user={@current_user} host={@host}>
        <.host_breadcrumb_label text="Settings" />
      </.host_header>
      <div :if={false} class="p-4 grid gap-8">
        <div class="flex w-full">
          <h2 class="text-lg grow font-medium col-span-full">Webhooks</h2>
          <.button size={:box} variant={:sublte}>
            <span>Add</span>
          </.button>
        </div>
      </div>
    </div>
    """
  end
end
