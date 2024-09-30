defmodule GitsWeb.HostLive.ManageEvent do
  use GitsWeb, :host_live_view

  attr :current, :boolean, required: true
  attr :label, :string, required: true
  attr :status, :atom, default: nil

  def wizard_step(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <%= if @current do %>
        <span class="inline-block h-1 w-10 rounded-full bg-blue-500"></span>
      <% else %>
        <span class="inline-block h-1 w-5 rounded-full bg-zinc-400 lg:ml-5"></span>
      <% end %>
      <span class="text-sm font-medium lg:inline"><%= @label %></span>
    </div>
    """
  end

  def wizard_wrapper(assigns) do
    title =
      case assigns.step do
        :location -> "Location"
        :event_details -> "Event Details"
      end

    assigns = assigns |> assign(:title, title)

    ~H"""
    <div class="mx-auto max-w-screen-xl items-start justify-between gap-8 lg:flex">
      <div class="flex gap-5 py-4 lg:grid lg:gap-8 lg:pt-24">
        <.wizard_step current={@step == :event_details} label="Event Details" />
        <.wizard_step current={@step == :location} label="Location" />
        <.wizard_step current={@step == :feature_graphics} label="Feature Graphics" />
        <.wizard_step current={@step == :tickets} label="Tickets" />
        <.wizard_step current={@step == :payment_method} label="Payment Method" />
        <.wizard_step current={@step == :overview} label="Overview" />
      </div>
      <div class="grid w-full max-w-screen-sm gap-8">
        <h1 class="col-span-full grow text-2xl font-semibold"><%= @title %></h1>
        <%= render_slot(@inner_block) %>
      </div>
      <div role="none"></div>
    </div>
    """
  end

  def render(%{live_action: :edit, step: :location} = assigns) do
    ~H"""
    <.wizard_wrapper step={@step}>
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
    <.wizard_wrapper step={:event_details}>
      <div class="grid grid-cols-2 gap-8">
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

  def handle_params(%{"edit" => "location"}, _uri, socket) do
    socket
    |> assign(:title, "Manage Event")
    |> assign(:step, :location)
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
    socket.assigns |> IO.inspect()

    next_step =
      case socket.assigns.step do
        :location -> "details"
      end

    socket
    |> push_patch(to: ~p"/h/test/events/event-id/manage?edit=#{next_step}", replace: true)
    |> noreply()
  end

  def handle_event("continue", _unsigned_params, socket) do
    socket
    |> push_patch(to: ~p"/h/test/events/event-id/manage?edit=location", replace: true)
    |> noreply()
  end

  def handle_event("close", _, socket) do
    socket |> push_navigate(to: ~p"/h/test/dashboard", replace: true) |> noreply()
  end
end
