defmodule GitsWeb.HostLive.ManageEvent do
  use GitsWeb, :host_live_view
  import GitsWeb.HostLive.ManageEventComponents

  def render(%{live_action: :edit, step: :location} = assigns) do
    ~H"""
    <.wizard_wrapper step={@step} subtitle="The Utlimate Cheese Festival">
      <div class="grid grid-cols-2 gap-8 pt-4">
        <fieldset class="col-span-full grid gap-4 lg:grid-cols-2">
          <legend class="col-span-full inline-flex text-sm font-medium">
            Where will your event take place?
          </legend>

          <label class="mt-1 flex gap-2 rounded-lg border p-4 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
            <input type="radio" name="event-location" checked class="peer sr-only" />
            <div class="grid grow gap-2">
              <span class="text-sm font-medium text-zinc-950">In-Person</span>
              <span class="text-sm text-zinc-500">
                Select a venue and prepare for an on-site event experience.
              </span>
            </div>
            <.icon
              name="hero-check-circle-mini"
              class="shrink-0 opacity-0 peer-checked:opacity-100 text-zinc-700"
            />
          </label>

          <label class="mt-1 flex gap-2 rounded-lg border p-4 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600 has-[:disabled]:opacity-60">
            <input type="radio" name="event-location" disabled class="peer sr-only" />
            <div class="grid grow gap-2">
              <span class="text-sm font-medium text-zinc-950">Online Only</span>
              <span class="text-sm text-zinc-500">
                Conduct your event entirely online, no physical venue needed.
              </span>
            </div>
            <.icon
              name="hero-check-circle-mini"
              class="opacity-0 shrink-0 peer-checked:opacity-100 text-zinc-700"
            />
          </label>
        </fieldset>

        <div class="col-span-full flex items-center gap-1 rounded-2xl border p-4">
          <div class="flex grow flex-wrap gap-x-2 gap-y-1">
            <h3 class="font-medium">No venue chosen</h3>
          </div>
          <span class="text-sm text-zinc-500">Choose venue</span>
          <div class="size-9 inline-flex shrink-0 items-center justify-center">
            <.icon name="hero-pencil-square" />
          </div>
        </div>

        <div :if={false} class="col-span-full flex items-start gap-1 rounded-2xl border p-4">
          <div class="flex grow flex-wrap gap-x-2 gap-y-1">
            <div class="flex w-full items-center gap-1">
              <h3 class="text-lg font-semibold">Artistry JHB</h3>
              <.icon name="hero-check-badge-mini" class="text-blue-500" />
            </div>
            <div class="flex items-center gap-2 text-zinc-500">
              <.icon name="hero-map" class="size-4" />
              <span class="text-sm">Owner: Artistry</span>
            </div>

            <div class="flex items-center gap-2 text-zinc-500">
              <.icon name="hero-key" class="size-4" />
              <span class="text-sm">Owner: Artistry</span>
            </div>
          </div>
          <div class="size-9 inline-flex shrink-0 items-center justify-center">
            <.icon name="hero-pencil-square" />
          </div>
        </div>

        <div class="col-span-full flex justify-end gap-6">
          <button class="rounded-lg px-4 py-2 text-zinc-950 hover:bg-zinc-100" phx-click="back">
            <span class="text-sm font-medium">Back</span>
          </button>
          <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
            <span class="text-sm font-medium">Continue</span>
          </button>
        </div>
      </div>
    </.wizard_wrapper>
    """
  end

  def render(%{live_action: :edit, step: :feature_graphics} = assigns) do
    ~H"""
    <.wizard_wrapper step={@step} subtitle="The Utlimate Cheese Festival">
      <div class="grid grid-cols-2 gap-4 pt-4">
        <fieldset class="col-span-full grid gap-4 lg:grid-cols-2">
          <legend class="col-span-full inline-flex text-sm font-medium">
            Upload a feature graphic
          </legend>

          <div class="aspect-[3/2] relative col-span-full mt-1 flex flex-col items-center justify-center gap-2 rounded-2xl border-2 border-dashed">
            <span class="text-sm text-zinc-600">
              <label class="has-[:focus]:ring-2">
                <span class="font-medium text-zinc-950">Choose a file</span>
                <input type="file" class="sr-only" />
              </label>
              to upload
            </span>
            <span class="max-w-80 text-center text-sm text-zinc-500">
              Upload a 3:2 image, at least 720x480 pixels, max 3MB.
            </span>
          </div>
          <div>
            <button></button>
          </div>
        </fieldset>

        <div class="col-span-full flex justify-end gap-6">
          <button class="rounded-lg px-4 py-2 text-zinc-950 hover:bg-zinc-100" phx-click="back">
            <span class="text-sm font-medium">Back</span>
          </button>
          <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
            <span class="text-sm font-medium">Continue</span>
          </button>
        </div>
      </div>
    </.wizard_wrapper>
    """
  end

  def render(%{live_action: :edit, step: :tickets} = assigns) do
    ~H"""
    <.wizard_wrapper step={@step} subtitle="The Utlimate Cheese Festival">
      <div class="grid grid-cols-2 gap-4">
        <div class="col-span-full flex justify-end gap-6">
          <button class="rounded-lg px-4 py-2 text-zinc-950 hover:bg-zinc-100" phx-click="back">
            <span class="text-sm font-medium">Back</span>
          </button>
          <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
            <span class="text-sm font-medium">Continue</span>
          </button>
        </div>
      </div>
    </.wizard_wrapper>
    """
  end

  def render(%{live_action: :edit, step: :payment_method} = assigns) do
    ~H"""
    <.wizard_wrapper step={@step} subtitle="The Utlimate Cheese Festival">
      <div class="grid grid-cols-2 gap-4">
        <div class="col-span-full flex justify-end gap-6">
          <button class="rounded-lg px-4 py-2 text-zinc-950 hover:bg-zinc-100" phx-click="back">
            <span class="text-sm font-medium">Back</span>
          </button>
          <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
            <span class="text-sm font-medium">Continue</span>
          </button>
        </div>
      </div>
    </.wizard_wrapper>
    """
  end

  def render(%{live_action: :edit, step: :summary} = assigns) do
    ~H"""
    <.wizard_wrapper step={@step} subtitle="The Utlimate Cheese Festival">
      <div class="grid grid-cols-2 gap-4">
        <div class="col-span-full flex justify-end gap-6">
          <button class="rounded-lg px-4 py-2 text-zinc-950 hover:bg-zinc-100" phx-click="back">
            <span class="text-sm font-medium">Back</span>
          </button>
          <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
            <span class="text-sm font-medium">Continue</span>
          </button>
        </div>
      </div>
    </.wizard_wrapper>
    """
  end

  def render(assigns) do
    ~H"""
    <.wizard_wrapper step={@step} subtitle="Create a new event">
      <div class="grid grid-cols-2 gap-8 pt-4">
        <label for="" class="col-span-full grid gap-1">
          <span class="text-sm font-medium">Name</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label for="" class="col-span-full grid gap-1">
          <span class="text-sm font-medium">Venue</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label for="" class="grid gap-1">
          <span class="text-sm font-medium">Start date</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label for="" class="grid gap-1">
          <span class="text-sm font-medium">End date</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label for="" class="col-span-full grid gap-1">
          <span class="text-sm font-medium">Description</span>
          <textarea rows="5" type="text" class="rounded-lg border-zinc-300 px-3 py-2 text-sm"></textarea>
        </label>

        <div class="col-span-full flex justify-end gap-6">
          <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
            <span class="text-sm font-medium">Continue</span>
          </button>
        </div>
      </div>
    </.wizard_wrapper>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> ok(:host_panel)
  end

  def handle_params(%{"edit" => current_destination}, _uri, socket) do
    current_destination |> IO.inspect(label: "fooooooooooooooooo")

    socket =
      case current_destination do
        "details" ->
          socket |> assign(:step, :event_details)

        "location" ->
          socket |> assign(:step, :location)

        "graphics" ->
          socket |> assign(:step, :feature_graphics)

        "tickets" ->
          socket |> assign(:step, :tickets)

        "payments" ->
          socket |> assign(:step, :payment_method)

        "summary" ->
          socket |> assign(:step, :summary)
      end

    socket
    |> assign(:title, "Manage Event")
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    title =
      case socket.assigns.live_action do
        :edit -> "Manage Event"
        _ -> "Create Event"
      end

    socket
    |> assign(:title, title)
    |> assign(:step, :event_details)
    |> noreply()
  end

  def handle_event("back", _unsigned_params, socket) do
    next_step =
      case socket.assigns.step do
        :location -> "details"
        :feature_graphics -> "location"
        :tickets -> "graphics"
        :payment_method -> "tickets"
        :summary -> "payments"
      end

    socket
    |> push_patch(to: ~p"/h/test/events/event-id/manage?edit=#{next_step}", replace: true)
    |> noreply()
  end

  def handle_event("continue", _unsigned_params, socket) do
    next_step =
      case socket.assigns.step do
        :event_details -> "location"
        :location -> "graphics"
        :feature_graphics -> "tickets"
        :tickets -> "payments"
        :payment_method -> "summary"
        :summary -> "summary"
      end

    socket
    |> push_patch(to: ~p"/h/test/events/event-id/manage?edit=#{next_step}", replace: true)
    |> noreply()
  end

  def handle_event("close", _, socket) do
    socket |> push_navigate(to: ~p"/h/test/dashboard", replace: true) |> noreply()
  end
end
