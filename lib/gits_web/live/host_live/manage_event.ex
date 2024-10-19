defmodule GitsWeb.HostLive.ManageEvent do
  use GitsWeb, :host_live_view

  def render(assigns) do
    ~H"""
    <div class="flex items-center gap-2 p-2">
      <.link
        replace={true}
        navigate={~p"/hosts/#{@host_handle}/dashboard"}
        class="flex items-center gap-2 rounded-lg h-9 px-2"
      >
        <.icon name="hero-chevron-left" class="size-5" />
        <span class="text-sm font-medium lg:inline hidden">Back</span>
      </.link>

      <div class="flex gap-2 grow items-center border-l truncate pl-4 text-sm font-medium">
        <span class="text-zinc-500 truncate">Events</span>
        <.icon name="hero-slash-micro" class="shrink-0" />
        <span class="truncate">Create an event</span>
      </div>

      <button class="flex size-9 lg:w-auto items-center gap-2 justify-center shrink-0 rounded-lg lg:px-4">
        <.icon name="hero-megaphone" class="size-5" />
        <span class="text-sm hidden lg:inline">Help</span>
      </button>
    </div>

    <h1 class="p-2 text-2xl font-semibold">Create an event</h1>

    <div class="grow flex lg:flex-row flex-col">
      <div class="w-full lg:max-w-64 p-2 flex lg:flex-col gap-4 lg:gap-6">
        <div
          :for={
            i <- [
              "Event details",
              "Time & place",
              "Feature Graphic",
              "Tickets",
              "Payout preferences",
              "Publish"
            ]
          }
          class="flex items-center gap-2"
        >
          <%= if i == "Event details" do %>
            <span class="inline-block h-1 w-6 lg:w-8 rounded-full bg-blue-500"></span>
            <span class="text-sm font-medium lg:inline"><%= i %></span>
          <% else %>
            <span class="inline-block h-1 lg:w-4 w-3 rounded-full bg-zinc-400 lg:ml-4"></span>
            <span class="hidden text-sm font-medium lg:inline"><%= i %></span>
          <% end %>
        </div>
      </div>

      <div class="lg:mt-0 mt-4">
        <div class="grid grow items-tart grid-cols-2 gap-6 px-2">
          <label class="col-span-full grid gap-1">
            <span class="text-sm font-medium">What is the name of your event?</span>
            <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
          </label>

          <label :if={false} class="col-span-full grid gap-1">
            <span class="text-sm font-medium">Give a brief event description</span>
            <textarea rows="5" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm"></textarea>
          </label>

          <div class="grid gap-1 col-span-full">
            <span class="text-sm font-medium">Give a brief event description</span>
            <div class="col-span-full h-64">
              <div id="editor" phx-hook="QuillEditor" class="h-[calc(100%-42px)]"></div>
            </div>
          </div>

          <fieldset class="col-span-full grid gap-4 lg:grid-cols-2 lg:gap-6">
            <legend class="col-span-full inline-flex text-sm font-medium">
              Event visibility
            </legend>

            <label class="mt-1 flex gap-2 rounded-lg border px-3 py-2 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
              <input type="radio" name="event-location" checked class="peer sr-only" />
              <div class="grid grow gap-1">
                <span class="text-sm font-medium text-zinc-950">Private</span>
                <span class="text-sm text-zinc-500">
                  Only people with the link to the event will be able to see it
                </span>
              </div>
              <.icon
                name="hero-check-circle-mini"
                class="shrink-0 text-zinc-700 opacity-0 peer-checked:opacity-100"
              />
            </label>

            <label class="mt-1 flex gap-2 rounded-lg border px-3 py-2 has-[:disabled]:opacity-60 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
              <input type="radio" name="event-location" class="peer sr-only" />
              <div class="grid grow gap-1">
                <span class="text-sm font-medium text-zinc-950">Public</span>
                <span class="text-sm text-zinc-500">
                  The event will be publicly discoverable on the platform
                </span>
              </div>
              <.icon
                name="hero-check-circle-mini"
                class="shrink-0 text-zinc-700 opacity-0 peer-checked:opacity-100"
              />
            </label>
          </fieldset>
        </div>
      </div>
    </div>

    <div class="px-2 py-4">
      <button class="h-9 flex px-4 bg-zinc-950 text-zinc-50 items-center rounded-lg">
        <span class="font-semibold text-sm">Continue</span>
      </button>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket |> assign(:current, false) |> ok()
  end
end
