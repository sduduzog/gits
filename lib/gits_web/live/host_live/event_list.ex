defmodule GitsWeb.HostLive.EventList do
  alias Gits.Hosts.Host
  use GitsWeb, :host_live_view

  require Ash.Query

  def mount(params, _session, socket) do
    host =
      Host
      |> Ash.Query.filter(handle == ^params["handle"])
      |> Ash.read_first!()
      |> IO.inspect()

    socket
    |> assign(:host_handle, host.handle)
    |> assign(:host_name, host.name)
    |> assign(:host_logo, host.logo)
    |> assign(:page_title, "The Ultimate Cheese Festival")
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <% navigation_items = [
      %{
        label: "All",
        current: @live_action == :all,
        href: ~p"/hosts/#{@host_handle}/events/all"
      },
      %{
        label: "Published",
        current: @live_action == :published,
        href: ~p"/hosts/#{@host_handle}/events"
      },
      %{
        label: "Drafts",
        current: @live_action == :drafts,
        href: ~p"/hosts/#{@host_handle}/events/drafts"
      }
    ] %>

    <div class="flex flex-wrap items-start justify-end">
      <div class="flex p-2 lg:p-0 grow gap-8">
        <.link
          :for={i <- navigation_items}
          patch={i.href}
          replace={true}
          class={[
            "text-sm text-zinc-400 rounded-lg font-medium",
            if(i.current, do: "text-zinc-950", else: "text-zinc-400")
          ]}
        >
          <%= i.label %>
        </.link>
      </div>
      <div>
        <button
          phx-click={JS.navigate(~p"/hosts/#{@host_handle}/events/new")}
          class="h-9 rounded-lg bg-zinc-950 inline-flex items-center gap-2 px-4 py-2 text-zinc-50 hover:bg-zinc-800"
        >
          <span class="text-sm font-semibold">Create event</span>
        </button>
      </div>
    </div>
    <div class="divide-y divide-zinc-100">
      <div :for={_ <- 1..3} class="py-4 flex gap-4 items-center">
        <div class="aspect-[3/2] h-20 bg-zinc-200 rounded-xl"></div>
        <div class="grid w-full gap-1.5 grow">
          <h2 class="font-semibold truncate">
            <.link navigate={~p"/hosts/#{@host_handle}/events/event_id"}>
              The Ultimate Cheese Festival
            </.link>
          </h2>
          <span class="text-sm text-zinc-500">5 Nov 2024, at 4:30 PM</span>
          <span class="text-sm text-zinc-500">5/40 tickets sold</span>
        </div>
        <div class="">
          <button class="size-9 inline-flex items-center justify-center">
            <.icon name="hero-ellipsis-vertical-mini" />
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_params(_, _, socket) do
    socket |> noreply()
  end
end
