defmodule GitsWeb.StorefrontLive.EventListing do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    socket |> ok()
  end
end
