defmodule GitsWeb.DashboardComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes
  import GitsWeb.CoreComponents

  embed_templates "dashboard/*"

  def sidebar_list(assigns) do
    assigns = assigns |> assign(:cheese, "cheddar")

    ~H"""
    <ul class="font-poppins grow space-y-2">
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  attr :base, :string, required: true
  attr :request_path, :string, required: true

  def dashboard_sidebar(assigns) do
    ~H"""
    <.sidebar>
      <.sidebar_item
        label="Dashboard"
        icon="hero-rectangle-group-mini"
        request_path={@request_path}
        to={@base}
        root={true}
      />
      <.sidebar_item
        label="Events"
        icon="hero-rectangle-group-mini"
        request_path={@request_path}
        to={@base <> "/events"}
      />
    </.sidebar>
    """
  end

  attr :base, :string, required: true
  attr :request_path, :string, required: true
  attr :back, :string, required: true

  def event_sidebar(assigns) do
    ~H"""
    <.sidebar>
      <.sidebar_item
        label="Event Overview"
        icon="hero-calendar-days-mini"
        request_path={@request_path}
        root={true}
        to={@base}
      />
      <.sidebar_item
        label="Settings"
        icon="hero-cog-6-tooth-mini"
        request_path={@request_path}
        to={@base <> "/settings"}
      />
      <.sidebar_item
        label="Tickets"
        icon="hero-ticket-mini"
        request_path={@request_path}
        to={@base <> "/tickets"}
      />
      <.sidebar_item
        label="Go back"
        icon="hero-arrow-left-mini"
        request_path={@request_path}
        root={true}
        to={@back}
      />
    </.sidebar>
    """
  end

  attr :base, :string, required: true
  attr :request_path, :string, required: true
  attr :back, :string, required: true

  def ticket_sidebar(assigns) do
    ~H"""
    <.sidebar>
      <.sidebar_item
        label="Event Overview"
        icon="hero-calendar-days-mini"
        request_path={@request_path}
        root={true}
        to={@base}
      />
      <.sidebar_item
        label="Settings"
        icon="hero-cog-6-tooth-mini"
        request_path={@request_path}
        to={@base <> "/settings"}
      />
      <.sidebar_item
        label="Tickets"
        icon="hero-ticket-mini"
        request_path={@request_path}
        to={@base <> "/tickets"}
      />
      <.sidebar_item
        label="Go back"
        icon="hero-arrow-left-mini"
        request_path={@request_path}
        root={true}
        to={@back}
      />
    </.sidebar>
    """
  end

  attr :label, :string, required: true
  attr :icon, :string, required: true
  attr :to, :string, required: true
  attr :request_path, :string, required: true
  attr :root, :boolean, default: false

  def sidebar_item(assigns) do
    current =
      if assigns.root,
        do: assigns.request_path == assigns.to,
        else: assigns.request_path |> String.starts_with?(assigns.to)

    assigns =
      assigns
      |> assign(:current, current)

    ~H"""
    <.sidebar_item_wrapper to={@to} current={@current} icon={@icon} label={@label} />
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
        class={["flex gap-3 rounded-lg p-4 hover:bg-gray-50", if(@current, do: "bg-gray-100")]}
      >
        <.icon name={@icon} class="text-gray-600" />
        <span class="text-sm font-medium"><%= @label %></span>
      </a>
    </li>
    """
  end

  def profile_group(assigns) do
    ~H"""
    <ul class="space-y-2 text-sm text-gray-700">
      <li class="grid"><a class="rounded-md p-2" href="/">Homepage</a></li>
      <li class="grid"><a class="rounded-md p-2 text-red-700" href="/sign-out">Log out</a></li>
    </ul>
    """
  end
end
