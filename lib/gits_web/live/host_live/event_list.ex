defmodule GitsWeb.HostLive.EventList do
  alias Gits.Hosts.Host
  use GitsWeb, :host_live_view

  require Ash.Query

  def mount(params, _session, socket) do
    host =
      Host
      |> Ash.Query.filter(handle == ^params["handle"])
      |> Ash.read_first!()

    socket
    |> assign(:host_handle, host.handle)
    |> assign(:host_name, host.name)
    |> assign(:host_logo, host.logo)
    |> assign(:page_title, "Events")
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

    <div class="flex items-center gap-2 p-2">
      <.link
        replace={true}
        navigate={~p"/hosts/#{@host_handle}/dashboard"}
        class="flex items-center gap-2 rounded-lg h-9 px-2"
      >
        <.icon name="hero-chevron-left" class="size-5" />
        <span class="text-sm font-semibold lg:inline hidden">Back</span>
      </.link>

      <div class="flex grow items-center border-l pl-4 text-sm font-medium">
        <span>Events</span>
        <!-- <.icon name="hero-slash-micro" /> -->
      </div>

      <button class="flex size-9 lg:w-auto items-center gap-2 justify-center rounded-lg lg:px-4">
        <.icon name="hero-megaphone" class="size-5" />
        <span class="text-sm hidden font-semibold lg:inline">Help</span>
      </button>

      <button
        phx-click={JS.navigate(~p"/hosts/#{@host_handle}/events/create-new")}
        class="flex border size-9 lg:w-auto items-center gap-2 justify-center rounded-lg lg:px-4"
      >
        <.icon name="hero-plus" class="size-5" />
        <span class="text-sm hidden font-semibold lg:inline">Create event</span>
      </button>
    </div>

    <h1 class="p-2 text-2xl font-semibold">Events</h1>

    <div class="flex flex-wrap items-start justify-endx p-2">
      <div class="flex grow gap-8 p-2 lg:p-0">
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
      <div></div>
    </div>
    <div class="divide-y divide-zinc-100 p-2">
      <div :for={_ <- []} class="flex items-center gap-4 py-4">
        <div class="aspect-[3/2] h-20 rounded-xl bg-zinc-200"></div>
        <div class="grid w-full grow gap-1.5">
          <h2 class="truncate font-semibold">
            <.link navigate={~p"/hosts/#{@host_handle}/events/event_id"}>
              The Ultimate Cheese Festival
            </.link>
          </h2>
          <span class="text-sm text-zinc-500">5 Nov 2024, at 4:30 PM</span>
          <span class="text-sm text-zinc-500">5/40 tickets sold</span>
        </div>
        <div class="">
          <button class="inline-flex size-9 items-center justify-center">
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
