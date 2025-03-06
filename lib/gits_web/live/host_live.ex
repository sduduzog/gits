defmodule GitsWeb.HostLive do
  alias GitsWeb.HostLive.Settings
  alias GitsWeb.HostLive.Events
  alias GitsWeb.HostLive.Dashboard
  alias GitsWeb.HostLive.Team
  use GitsWeb, :verified_routes

  def assign_sidebar_items(socket, module, host) do
    action = socket.assigns.live_action

    Phoenix.Component.assign(socket, :sidebar_items, [
      {"Home", "icon-[ri--home-line]", Routes.host_dashboard_path(socket, :home, host.handle),
       module == Dashboard, [], nil},
      {"Events", "icon-[ri--calendar-line]", Routes.host_events_path(socket, :index, host.handle),
       module == Events, [], nil},
      # {"Admissions", "icon-[ri--settings-3-line]", false, module == Settings, [], nil},
      # {"Engagements", "icon-[ri--settings-3-line]", false, module == Settings, [], nil},
      {"Team", "icon-[ri--settings-3-line]", false, IO.inspect(module == Team),
       [
         {"Members", ~p"/hosts/#{host.handle}/team/members", action == :members, nil}
       ], nil},
      {"Settings", "icon-[ri--settings-3-line]", false, IO.inspect(module == Settings),
       [
         {"General", Routes.host_settings_path(socket, :general, host.handle), action == :general,
          nil},
         {"Billing & Payouts", Routes.host_settings_path(socket, :billing, host.handle),
          action == :billing, nil}
       ], nil}
    ])
  end
end
