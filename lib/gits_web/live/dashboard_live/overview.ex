defmodule GitsWeb.DashboardLive.Overview do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
socket =   socket |>  assign(:nav, [])
{:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next}}
  end
end
