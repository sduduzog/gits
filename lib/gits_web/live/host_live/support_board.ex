defmodule GitsWeb.HostLive.SupportBoard do
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    socket |> ok(:host)
  end
end
