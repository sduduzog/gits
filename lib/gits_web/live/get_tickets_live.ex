defmodule GitsWeb.GetTicketsLive do
  use GitsWeb, :live_view
  require Ash.Query
  alias Gits.Events.Event

  def mount(%{"id" => event_id}, _session, socket) do
    event =
      Event
      |> Ash.Query.filter(id: event_id)
      |> Gits.Events.read_one!()

    socket =
      socket
      |> assign(:event, event)

    {:ok, socket}
  end
end
