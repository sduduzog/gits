defmodule GitsWeb.HostLive.CreateEvent do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    {"Create an event", "Start crafting your event experience.", :create_event}
    socket |> ok(:host_panel)
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-screen-md lg:pt-8">
      <h1 class="grow items-center truncate text-2xl font-semibold">
        Create a new event
      </h1>

      <div class="grid grid-cols-2 gap-6 pt-4">
        <label class="col-span-full grid gap-1">
          <span class="text-sm font-medium">What is the name of your event?</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <div class="col-span-full overflow-visible min-h-40">
          <div
            id="quill-editor"
            phx-hook="QuillEditor"
            class="h-[calc(100%-42px)] text-sm font-poppins block"
          >
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
        <div class="flex col-span-full justify-end">
          <button
            phx-click={JS.navigate(~p"/hosts/test/events/event_id/settings/time-and-place")}
            class="text-zinc-50 bg-zinc-950 px-4 rounded-lg py-2"
          >
            <span class="text-sm font-semibold">Create event</span>
          </button>
        </div>
      </div>
    </div>
    """
  end
end
