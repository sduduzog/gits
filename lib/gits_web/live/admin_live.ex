defmodule GitsWeb.AdminLive do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    ok(socket, false)
  end
end
