defmodule GitsWeb.HostLive do
  alias GitsWeb.HostLive.Settings
  alias GitsWeb.HostLive.Events
  alias GitsWeb.HostLive.Dashboard
  use GitsWeb, :verified_routes

  def assign_sidebar_items(socket, module, host) do
    action = socket.assigns.live_action

    Phoenix.Component.assign(socket, :sidebar_items, [
      {"Home", "icon-[ri--home-line]", Routes.host_dashboard_path(socket, :home, host.handle),
       module == Dashboard, [], nil},
      {"Events", "icon-[ri--calendar-line]", Routes.host_events_path(socket, :index, host.handle),
       module == Events, [], nil},
      {"Settings", "icon-[ri--settings-3-line]", false, module == Settings,
       [
         {"General", Routes.host_settings_path(socket, :general, host.handle), action == :general,
          nil},
         {"Billing & Payouts", Routes.host_settings_path(socket, :billing, host.handle),
          action == :billing, nil}
       ], nil}
    ])
  end
end
