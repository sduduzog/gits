defmodule GitsWeb.HostComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes
  alias Phoenix.LiveView.JS

  alias GitsWeb.HostLive.{Dashboard, Events, Settings, ViewEvent}

  import GitsWeb.CoreComponents

  def host_navigation_items(host, view, live_action) do
    [
      {"Home", "i-lucide-home", ~p"/hosts/#{host.handle}/dashboard",
       Enum.any?([Dashboard], &(&1 == view)), []},
      {"Events", "i-lucide-calendar-range", ~p"/hosts/#{host.handle}/events",
       Enum.any?([Events], &(&1 == view)), []},
      {"Settings", "i-lucide-settings", ~p"/hosts/#{host.handle}/settings",
       Enum.any?([Settings], &(&1 == view)),
       [
         # {"General", "", false},
         # {"Members", "", false},
         # {"Billing", "", false},
         {"API", ~p"/hosts/#{host.handle}/settings/api", live_action == :api}
       ]}
    ]
  end

  def host_menu_items(user, _host) do
    [
      [
        {user.email, nil, nil, false},
        {"Profile", "i-lucide-user", ~p"/settings/profile", false}
      ],
      # [
      # {"Organization", nil, nil, false}
      # {"Settings", "i-lucide-settings", ~p"/hosts/#{@host.handle}/settings", false}
      # ],
      [{"Sign out", "i-lucide-log-out", ~p"/sign-out", false}]
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
    <header class="sticky top-0 grid grid-cols-[auto_auto_1fr] lg:grid-cols-[1fr_auto] items-center justify-between gap-2 bg-white p-2 pr-4 shadow-sm lg:static lg:pl-0 lg:shadow-none">
      <div class="flex overflow-hidden items-center gap-1 text-sm">
        {render_slot(@inner_block)}
      </div>
      <div
        phx-click-away={
          JS.hide(
            to: "div#header-menu[role=menu]",
            transition:
              {"transition ease-in duration-75", "transform opacity-100 scale-100",
               "transform opacity-0 scale-95"}
          )
        }
        class="relative"
      >
        <.button
          size={:box}
          variant={:ghost}
          phx-click={
            JS.toggle(
              to: "div#header-menu[role=menu]",
              in:
                {"transition ease-out duration-100", "transform opacity-0 scale-95",
                 "transform opacity-100 scale-100"},
              out:
                {"transition ease-in duration-75", "transform opacity-100 scale-100",
                 "transform opacity-0 scale-95"}
            )
          }
          id="menu-button"
        >
          <.icon name="i-lucide-building-2" />
          <span class="hidden lg:inline-flex">{@host.name}</span>
          <.icon name="i-lucide-chevron-down" />
        </.button>

        <div
          id="header-menu"
          class="absolute right-0 top-full z-20 hidden w-56 origin-top-right divide-y divide-zinc-100 rounded-md bg-white shadow-lg ring-1 ring-black/5 focus:outline-none"
          role="menu"
          aria-orientation="vertical"
          aria-labelledby="menu-button"
          tabindex="-1"
        >
          <div
            :for={{items, outer_index} <- Enum.with_index(host_menu_items(@current_user, @host))}
            class="py-1"
            role="none"
          >
            <%= for {{name, icon,href, badge}, index} <- Enum.with_index(items) do %>
              <%= if href do %>
                <.link
                  navigate={href}
                  class="flex items-center gap-2 px-4 py-2 text-sm font-medium text-zinc-700 hover:bg-zinc-50 active:bg-zinc-100 active:text-zinc-900 active:outline-none"
                  role="menuitem"
                  tabindex="-1"
                  id={"menu-item-#{outer_index}-#{index}"}
                >
                  <.icon :if={icon} name={icon} />
                  <span>{name}</span>
                  <span
                    :if={badge}
                    class="inline-flex items-center gap-x-1.5 rounded-md bg-white px-2 py-1 text-xs font-medium text-gray-900 ring-1 ring-inset ring-gray-200"
                  >
                    {badge}
                  </span>
                </.link>
              <% else %>
                <div class="px-4 py-1" role="none">
                  <p class="truncate text-sm text-zinc-400" role="none">
                    {name}
                  </p>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>

      <.button
        size={:box}
        variant={:ghost}
        phx-click={JS.show(to: "aside")}
        class="md:hidden shrink-0"
      >
        <.icon name="i-lucide-menu" />
      </.button>
    </header>
    """
  end
end
