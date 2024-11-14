defmodule GitsWeb.MyLive.Settings do
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
    |> ok()
  end
end
