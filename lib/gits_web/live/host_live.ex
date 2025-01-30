defmodule GitsWeb.HostLive do
  alias GitsWeb.HostLive.Settings
  alias GitsWeb.HostLive.Events
  alias GitsWeb.HostLive.Dashboard
  use GitsWeb, :verified_routes

  def assign_sidebar_items(socket, module, host) do
    action = socket.assigns.live_action

    Phoenix.Component.assign(socket, :sidebar_items, [
      {"Home", "ri--home-line", Routes.host_dashboard_path(socket, :home, host.handle),
       module == Dashboard, [], nil},
      {"Events", "ri--calendar-line", Routes.host_events_path(socket, :index, host.handle),
       module == Events, [], nil},
      # {"Customers", "ri--calendar-line", Routes.host_events_path(socket, :index, host.handle),
      #  module == Events, [], nil},
      # {"Team", "ri--team-line", false, false, [], nil},
      {"Settings", "ri--settings-3-line", false, module == Settings,
       [
         {"Billing & Payouts", Routes.host_settings_path(socket, :billing, host.handle),
          action == :billing, nil}
         # {"API", ~p"/hosts/#{host.handle}/settings/api", false, nil}
       ], nil}
    ])
  end
end
