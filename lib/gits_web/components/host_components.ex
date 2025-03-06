defmodule GitsWeb.HostComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes
  alias Phoenix.LiveView.JS

  alias GitsWeb.HostLive.{Dashboard, Events, Settings}

  import GitsWeb.CoreComponents

  def host_navigation_items(host, view, live_action) do
    [
      {"Home", "ri--home-line", ~p"/hosts/#{host.handle}/dashboard",
       Enum.any?([Dashboard], &(&1 == view)), [], nil},
      {"Events", "ri--calendar-line", ~p"/hosts/#{host.handle}/events",
       Enum.any?([Events], &(&1 == view)), [], nil},
      {"Team", "ri--team-line", false, Enum.any?([Settings], &(&1 == view)), [], nil},
      {"Settings", "ri--settings-3-line", false, Enum.any?([Settings], &(&1 == view)),
       [
         # {"General", "", false},
         # {"Members", "", false},
         # {"Billing", "", false},
         {"API", ~p"/hosts/#{host.handle}/settings/api", live_action == :api, nil}
       ], nil}
    ]
  end

  def host_menu_items(user, _handle) do
    [
      [
        {user.email, nil, nil, false},
        {"Profile", "lucide--user", ~p"/settings", false}
      ],
      # [
      # {"Organization", nil, nil, false}
      # {"Settings", "lucide--settings", ~p"/hosts/#{@host.handle}/settings", false}
      # ],
      [{"Sign out", "lucide--log-out", ~p"/sign-out", false}]
    ]
  end

  def host_breadcrumb_label(assigns) do
    ~H"""
    <div class="items-center truncate rounded-lg border border-transparent p-2 text-sm/5 font-semibold">
      <span class="truncate ">
        {@text}
      </span>
    </div>
    """
  end

  def host_breadcrumb_button(assigns) do
    ~H"""
    <.button href={@href} variant={:ghost} size={:none} class="group max-w-48 p-2">
      <span class="truncate text-zinc-400 group-hover:text-zinc-600">
        {@text}
      </span>
    </.button>
    """
  end

  def host_header(assigns) do
    ~H"""
    <header class="sticky top-0 z-10 grid grid-cols-[1fr_auto_auto] items-center justify-between gap-2 bg-white p-2 pr-2 shadow-sm lg:static lg:grid-cols-[1fr_auto] lg:pl-0 lg:shadow-none">
      <div class="flex items-center gap-1 overflow-hidden text-sm">
        {render_slot(@inner_block)}
      </div>

      <.button
        size={:box}
        variant={:ghost}
        phx-click={JS.show(to: "aside")}
        class="shrink-0 md:hidden"
      >
        <.icon class="icon-[lucide--menu]" />
      </.button>
    </header>
    """
  end
end
