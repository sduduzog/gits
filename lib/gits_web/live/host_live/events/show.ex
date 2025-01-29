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
      |> Ash.Query.load([
        :start_date_invalid?,
        :end_date_invalid?,
        :poster_invalid?,
        :venue_invalid?,
        :has_paid_tickets?,
        :total_ticket_types,
        :ticket_types
      ])
      |> Ash.read_one(actor: assigns.current_user)
      |> case do
        {:ok, %Event{} = event} ->
          socket
          |> assign(:event, event)
          |> assign(
            :event_has_issues?,
            [
              event.start_date_invalid?,
              event.end_date_invalid?,
              event.poster_invalid?,
              event.venue_invalid?
            ]
            |> Enum.filter(& &1)
            |> Enum.any?()
          )
          |> assign(:tickets_flag, event.total_ticket_types)
          |> assign(
            :paid_tickets_issue?,
            not assigns.payment_method_ready and event.has_paid_tickets?
          )
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
