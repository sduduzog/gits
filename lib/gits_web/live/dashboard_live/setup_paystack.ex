defmodule GitsWeb.DashboardLive.SetupPaystack do
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    socket = socket |> assign(:slug, params["slug"]) |> assign(:title, "Setup Paystack")
    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next_detail}}
  end
end
