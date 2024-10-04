defmodule GitsWeb.HostLive.Components do
  use Phoenix.Component
  use GitsWeb, :verified_routes

  # alias Phoenix.LiveView.JS

  attr :current, :boolean, default: false
  attr :label, :string, required: true
  attr :status, :atom, default: nil

  def wizard_step(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <%= if @current do %>
        <span class="inline-block h-1 w-6 lg:w-8 rounded-full bg-blue-500"></span>
        <span class="text-sm font-medium lg:inline"><%= @label %></span>
      <% else %>
        <span class="inline-block h-1 lg:w-4 w-3 rounded-full bg-zinc-400 lg:ml-4"></span>
        <span class="hidden text-sm font-medium lg:inline"><%= @label %></span>
      <% end %>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :subtitle, :string, required: true
  slot :steps, required: true
  slot :inner_block, required: true

  def wizard_wrapper(assigns) do
    ~H"""
    <div class="mx-auto max-w-screen-xl items-start justify-between gap-8 lg:flex">
      <div class="flex justify-between py-4 lg:grid lg:gap-8 lg:pt-16">
        <%= render_slot(@steps) %>
      </div>
      <div class="grid w-full max-w-screen-sm gap-8 lg:pt-14">
        <div class="space-y-1">
          <h1 class="col-span-full grow text-2xl font-semibold"><%= @title %></h1>
          <h2 class="text-zinc-600"><%= @subtitle %></h2>
        </div>
        <%= render_slot(@inner_block) %>
      </div>
      <div role="none"></div>
    </div>
    """
  end
end
