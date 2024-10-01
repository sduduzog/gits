defmodule GitsWeb.HostLive.ManageEventComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes

  # alias Phoenix.LiveView.JS

  attr :current, :boolean, required: true
  attr :label, :string, required: true
  attr :status, :atom, default: nil

  def wizard_step(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <%= if @current do %>
        <span class="inline-block h-1 w-8 rounded-full bg-blue-500"></span>
        <span class="text-sm font-medium lg:inline"><%= @label %></span>
      <% else %>
        <span class="inline-block h-1 w-4 rounded-full bg-zinc-400 lg:ml-4"></span>
        <span class="hidden text-sm font-medium lg:inline"><%= @label %></span>
      <% end %>
    </div>
    """
  end

  attr :step, :atom, required: true
  attr :subtitle, :string, required: true
  slot :inner_block, required: true

  def wizard_wrapper(assigns) do
    title =
      case assigns.step do
        :location -> "Location"
        :event_details -> "Event Details"
        :feature_graphic -> "Feature Graphic"
        :tickets -> "Tickets"
        :payment_method -> "Payment Method"
        :summary -> "Summary"
      end

    assigns = assigns |> assign(:title, title)

    ~H"""
    <div class="mx-auto max-w-screen-xl items-start justify-between gap-8 lg:flex">
      <div class="flex justify-between gap-5 py-4 lg:grid lg:gap-8 lg:pt-36">
        <.wizard_step current={@step == :event_details} label="Event Details" />
        <.wizard_step current={@step == :location} label="Location" />
        <.wizard_step current={@step == :feature_graphic} label="Feature Graphic" />
        <.wizard_step current={@step == :tickets} label="Tickets" />
        <.wizard_step current={@step == :payment_method} label="Payment Method" />
        <.wizard_step current={@step == :summary} label="Summary" />
      </div>
      <div class="grid w-full max-w-screen-sm gap-8">
        <div>
          <h1 class="col-span-full grow text-2xl font-semibold"><%= @title %></h1>
          <h2 class="text-lg text-zinc-600"><%= @subtitle %></h2>
        </div>
        <%= render_slot(@inner_block) %>
      </div>
      <div role="none"></div>
    </div>
    """
  end
end
