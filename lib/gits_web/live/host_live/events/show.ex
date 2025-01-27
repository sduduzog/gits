defmodule GitsWeb.HostLive.Events.Show do
  import GitsWeb.HostComponents
  require Ash.Query
  alias Gits.Storefront.Event
  use GitsWeb, :live_component

  def update(assigns, socket) do
    if is_nil(assigns.event_id) do
      socket
      |> assign(:event, nil)
    else
      Event
      |> Ash.Query.filter(host.id == ^assigns.host_id and public_id == ^assigns.event_id)
      |> Ash.Query.load([:total_ticket_types])
      |> Ash.read_one(actor: assigns.current_user)
      |> case do
        {:ok, %Event{} = event} ->
          socket
          |> assign(:event, event)
          |> assign(:tickets_flag, event.total_ticket_types)
      end
    end
    |> assign(:current_user, assigns.current_user)
    |> assign(:handle, assigns.handle)
    |> assign(:host_state, assigns.host_state)
    |> assign(:host_name, assigns.host_name)
    |> assign(:host_id, assigns.host_id)
    |> assign(:action, assigns.live_action)
    |> ok()
  end
end
