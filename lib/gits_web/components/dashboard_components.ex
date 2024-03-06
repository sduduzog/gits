defmodule GitsWeb.DashboardComponents do
  use Phoenix.Component
  import GitsWeb.CoreComponents

  def sidebar_list(assigns) do
    assigns = assigns |> assign(:cheese, "cheddar")

    ~H"""
    <ul class="grow space-y-2">
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  attr :label, :string, required: true
  attr :icon, :string, required: true
  attr :to, :string, required: true

  def sidebar_list_item(assigns) do
    ~H"""
    <li>
      <a href={@to} class="p-4 rounded-lg flex gap-3 hover:bg-gray-100">
        <.icon name={@icon} class="text-gray-600" />
        <span class="text-sm"><%= @label %></span>
      </a>
    </li>
    """
  end
end
