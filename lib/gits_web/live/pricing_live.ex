defmodule GitsWeb.PricingLive do
  use GitsWeb, :live_view

  def handle_params(_unsigned_params, _uri, socket) do
    socket
    |> assign(:interval, :monthly)
    |> noreply()
  end
end
