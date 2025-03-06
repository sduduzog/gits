defmodule GitsWeb.DashboardComponents do
  use Phoenix.Component
  import GitsWeb.CoreComponents, only: [icon: 1]
  use GitsWeb, :verified_routes

  def sidebar_item(%{children: children} = assigns) when children != [] do
    ~H"""
    <details class="grid" open={@current}>
      <summary class="flex items-center gap-4 rounded-lg p-2 hover:text-zinc-800">
        <.icon class={"#{@icon} shrink-0"} />
        <span>{@label}</span>
      </summary>
      <.sidebar_item_child
        :for={{label, href, current, flag} <- @children}
        label={label}
        href={href}
        current={current}
        flag={flag}
      />
    </details>
    """
  end

  def sidebar_item(assigns) do
    ~H"""
    <.link
      aria-selected={"#{@current}"}
      navigate={@href}
      class="flex items-center gap-4 rounded-lg p-2 hover:text-zinc-800 aria-selected:font-semibold aria-selected:text-zinc-800"
    >
      <.icon class={"#{@icon} shrink-0"} />
      <span>{@label}</span>
    </.link>
    """
  end

  def sidebar_item_child(assigns) do
    ~H"""
    <.link
      aria-selected={"#{@current}"}
      class="rounded-lg pl-4 aria-selected:text-zinc-950 aria-selected:font-semibold hover:text-zinc-800"
      navigate={@href}
    >
      <div class="border-l border-zinc-100 p-2 pl-6">{@label}</div>
    </.link>
    """
  end
end
