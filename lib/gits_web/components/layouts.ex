defmodule GitsWeb.Layouts do
  alias GitsWeb.HostLive.{Dashboard, ListEvents, Settings, ViewEvent}
  use GitsWeb, :html

  embed_templates "layouts/*"

  def host_navigation_items(host, view, live_action) do
    [
      {"Home", "i-lucide-home", ~p"/hosts/#{host.handle}/dashboard",
       Enum.any?([Dashboard], &(&1 == view)), []},
      {"Events", "i-lucide-calendar-range", ~p"/hosts/#{host.handle}/events",
       Enum.any?([ListEvents, ViewEvent], &(&1 == view)),
       [
         {"All", ~p"/hosts/#{host.handle}/events", live_action == :all},
         {"Published", ~p"/hosts/#{host.handle}/events/published", live_action == :published},
         {"Completed", ~p"/hosts/#{host.handle}/events/completed", live_action == :completed},
         {"Drafts", ~p"/hosts/#{host.handle}/events/drafts", live_action == :drafts},
         {"Archived", ~p"/hosts/#{host.handle}/events/archived", live_action == :archived}
       ]},
      {"Settings", "i-lucide-settings", ~p"/hosts/#{host.handle}/settings",
       Enum.any?([Settings], &(&1 == view)), []}
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

  def host_breadcrumbs(host, view, live_action) do
    host_navigation_items(host, view, live_action)
    |> Enum.filter(fn {_, _, _, current, _} ->
      current
    end)
    |> Enum.map(fn {label, _, href, _, subitems} ->
      subitems =
        Enum.filter(subitems, fn {_, _, current} ->
          current
        end)
        |> Enum.map(fn {label, href, _} ->
          {label, href}
        end)

      [{label, href}] ++ subitems
    end)
    |> hd()
  end
end
