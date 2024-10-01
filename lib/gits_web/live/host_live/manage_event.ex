defmodule GitsWeb.HostLive.ManageEvent do
  use GitsWeb, :host_live_view
  import GitsWeb.HostLive.ManageEventComponents

  def render(%{live_action: :edit, step: :location} = assigns) do
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

  def render(%{live_action: :edit, step: :feature_graphics} = assigns) do
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
