defmodule GitsWeb.DashboardLive.SetupPaystack do
  alias Gits.Dashboard.Account
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    form = Account |> AshPhoenix.Form.for_create(:create)

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Setup Paystack")
      |> assign(:form, form)
      |> assign(:rad, nil)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next_detail}}
  end
end
