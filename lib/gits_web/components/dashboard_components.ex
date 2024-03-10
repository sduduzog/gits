defmodule GitsWeb.DashboardComponents do
  use Phoenix.Component
  import GitsWeb.CoreComponents

  def sidebar_list(assigns) do
    assigns = assigns |> assign(:cheese, "cheddar")

    ~H"""
    <ul class="grow space-y-2 font-poppins">
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  attr :label, :string, required: true
  attr :icon, :string, required: true
  attr :to, :string, required: true
  attr :request_path, :string, required: true
  attr :root, :boolean, default: false

  def sidebar_list_item(assigns) do
    current =
      if assigns.root,
        do: assigns.request_path == assigns.to,
        else: assigns.request_path |> String.starts_with?(assigns.to)

    assigns =
      assigns
      |> assign(:current, current)

    ~H"""
    <li>
      <a
        href={@to}
        class={[
          "p-4 rounded-lg flex gap-3 hover:bg-gray-50",
          "foo",
          if(@current, do: "bg-gray-100")
        ]}
      >
        <.icon name={@icon} class="text-gray-600" />
        <span class="text-sm font-medium"><%= @label %></span>
      </a>
    </li>
    """
  end

  def profile_group(assigns) do
    ~H"""
    <ul class="text-sm space-y-2 text-gray-700">
      <li class="grid"><a class="p-2 rounded-md" href="/">Homepage</a></li>
      <li class="grid"><a class="p-2 rounded-md text-red-700" href="/sign-out">Log out</a></li>
    </ul>
    """
  end
end
