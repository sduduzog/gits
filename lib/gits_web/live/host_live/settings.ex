defmodule GitsWeb.HostLive.Settings do
  use GitsWeb, :host_live_view

  def section(%{current: :payouts} = assigns) do
    ~H"""
    <div>payouts</div>
    """
  end

  def section(assigns) do
    ~H"""
    <div class="grid gap-8">
      <fieldset class="grid gap-1 lg:grid-cols-[theme(space.64)_1fr]">
        <div>
          <legend class="text-sm font-medium">Name</legend>
          <span class="text-sm text-zinc-500">Changes will update all URLs</span>
        </div>
        <div class="grid max-w-screen-sm gap-4">
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2" />
          <div class="">
            <span></span>
            <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2" />
          </div>
        </div>
      </fieldset>

      <fieldset class="grid gap-1 lg:grid-cols-[theme(space.64)_1fr]">
        <div>
          <legend class="text-sm font-medium">Logo</legend>
          <span class="text-sm text-zinc-500">
            Update your host account logo
          </span>
        </div>
        <div class="flex max-w-screen-sm items-center gap-4">
          <div class="size-20 shrink-0 rounded-lg border p-4"></div>
          <div class="flex w-full justify-between">
            <label class="inline-block cursor-pointer rounded-lg bg-zinc-50 px-4 py-2 hover:bg-zinc-100">
              <span class="text-sm font-medium">Change</span>
              <input type="file" class="hidden" />
            </label>
            <button :if={false} class="rounded-lg bg-zinc-100 px-4 py-2">
              <span class="text-sm font-medium">Change</span>
            </button>
          </div>
        </div>
      </fieldset>
    </div>
    """
  end

  def renders(assigns) do
    ~H"""
    <div class="space-y-8">
      <h1 class="col-span-full pt-5 text-2xl font-semibold">Settings</h1>
      <div class="relative flex flex-wrap gap-2">
        <.link
          :for={
            item <- [
              %{label: "General", current: @live_action == :general, href: ~p"/hosts/test/settings"},
              %{
                label: "Payouts",
                current: @live_action == :payouts,
                href: ~p"/hosts/test/settings/payouts"
              }
            ]
          }
          patch={item.href}
          class={[
            "relative grid rounded-lg px-4 py-2 text-zinc-500 hover:bg-zinc-100",
            if(item.current, do: "bg-black/5 text-zinc-950", else: "text-zinc-500")
          ]}
        >
          <span class="text-sm font-medium"><%= item.label %></span>
        </.link>
      </div>
      <.section current={@live_action} />
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>settings</div>
    """
  end

  def mount(_params, _session, socket) do
    socket |> ok()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket |> noreply()
  end
end
