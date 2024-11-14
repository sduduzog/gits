defmodule GitsWeb.MyLive.Tickets do
  use GitsWeb, :live_view

  def mount(_, _, %{assigns: %{live_action: :show}} = socket) do
    socket |> assign(:page_title, "General") |> ok()
  end

  def mount(_, _, socket) do
    socket |> assign(:page_title, "Tickets") |> ok()
  end
end
