defmodule GitsWeb.DashboardLive.Events do
  use GitsWeb, :dashboard_live_view
  require Ash.Query

  def handle_params(_unsigned_params, _uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    account = account |> Ash.load!([events: [:address]], actor: user)

    socket
    |> assign(:events, account.events)
    |> noreply()
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-xl font-semibold">Events</h1>
    <div class="flex items-center justify-between gap-4">
      <div class="grow"></div>
      <button
        class="rounded-xl bg-zinc-800 px-4 py-3 text-sm font-medium text-white hover:bg-zinc-600"
        phx-click={JS.navigate(~p"/accounts/#{@slug}/events/new")}
      >
        Create event
      </button>
    </div>

    <div class="grid gap-4 divide-y divide-zinc-100 md:gap-6">
      <div :for={event <- @events} class="flex items-center gap-2 pt-4 md:gap-6 md:pt-6">
        <.link
          navigate={~p"/accounts/#{@slug}/events/#{event.id}"}
          class="aspect-[3/2] w-32 shrink-0 overflow-hidden rounded-xl bg-zinc-200"
        >
          <img
            src={Gits.Bucket.get_feature_image_path(@account.id, event.id)}
            alt="event image"
            id={"event-image-#{event.id}"}
            phx-hook="ImgSrcFallback"
          />
        </.link>
        <div class="line-clamp-3 grid grow gap-1 md:gap-2">
          <h1 class="w-full text-base font-semibold md:w-auto">
            <.link navigate={~p"/accounts/#{@slug}/events/#{event.id}"}><%= event.name %></.link>
          </h1>
          <div class="w-full grow gap-2 text-sm text-zinc-500 md:w-auto">
            <span>
              <%= event.starts_at
              |> Timex.format!("%b %e, %Y at %H:%M %p", :strftime) %>
            </span>
            <span class="inline-flex px-0.5">&bull;</span>
            <%= if is_nil(event.address) do %>
              <span>Address not set</span>
            <% else %>
              <span><%= event.address.display_name %> &bull; <%= event.address.city %></span>
            <% end %>
          </div>
          <span class="hidden text-sm text-zinc-500 md:inline-flex">0/1 tickets sold</span>
        </div>
        <div class="shrink-0">
          <button class="flex rounded-lg p-1 hover:bg-zinc-50">
            <.icon name="hero-ellipsis-vertical-mini" />
          </button>
        </div>
      </div>
    </div>
    """
  end
end
