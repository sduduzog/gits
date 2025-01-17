defmodule GitsWeb.PricingLive do
  use GitsWeb, :live_view

  def handle_params(unsigned_params, uri, socket) do
    socket
    |> assign(:interval, :monthly)
    |> noreply()
  end
end
