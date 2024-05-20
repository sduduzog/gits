defmodule GitsWeb.DashboardLive.SetupPaystack do
  alias Gits.PaystackApi
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

  def handle_params(_unsigned_params, _uri, socket) do
    PaystackApi.list_banks()
    |> IO.inspect()

    {:noreply, socket}
  end
end
