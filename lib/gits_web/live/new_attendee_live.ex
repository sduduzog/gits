defmodule GitsWeb.NewAttendeeLive do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event(event, _unsigned_params, socket) do
    IO.inspect(event)
    {:noreply, socket}
  end
end
