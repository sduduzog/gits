defmodule GitsWeb.HostLive.ViewEvent do
  alias Gits.Storefront.{Event, Order, Ticket}
  use GitsWeb, :live_view
  require Ash.Query

  embed_templates "view_event_templates/*"

  def mount(_params, _session, socket) do
    case socket.assigns.current_user do
      nil ->
        socket
        |> assign(:page_title, "Unauthorized")
        |> ok(:unauthorized)

      _ ->
        socket |> ok(:host)
    end
  end

  def handle_params(%{"public_id" => public_id} = unsigned_params, _uri, socket) do
    Event
    |> Ash.Query.filter(public_id == ^public_id)
    |> Ash.Query.load([:published?])
    |> Ash.read_one()
    |> case do
      {:ok, %Event{} = event} ->
        socket
        |> assign(:event, event)
        |> assign(:event_published?, event.published?)
        |> assign(:page_title, "Events / #{event.name}")

      {:ok, nil} ->
        socket |> assign(:error, :event_not_found)
    end
    |> show_publish_modal(unsigned_params)
    |> show_archive_modal(unsigned_params)
    |> list_attendees()
    |> noreply()
  end

  defp list_attendees(%{assigns: %{live_action: :attendees}} = socket) do
    socket.assigns.event
    |> Ash.load(
      orders:
        Ash.Query.filter(Order, state == :completed)
        |> Ash.Query.load(tickets: Ash.Query.load(Ticket, :ticket_type_name))
    )
    |> case do
      {:ok, event} ->
        attendees =
          Enum.flat_map(event.orders, & &1.tickets)
          |> Enum.map(&%{name: "Unknown", ticket: &1.ticket_type_name})

        socket
        |> assign(:attendees, attendees)
    end
  end

  defp list_attendees(socket), do: socket

  def handle_event("publish", _unsigned_params, socket) do
    %{event_id: event_id} = socket.assigns

    Event.publish_event(event_id)
    |> case do
      {:ok, event} ->
        event
    end
    |> Ash.load([:published?])
    |> case do
      {:ok, event} -> socket |> assign(:event_published?, event.published?)
    end
    |> noreply()
  end

  defp show_publish_modal(socket, %{"publish" => _event_id}) do
    socket
    |> assign(:show_publish_modal, true)
  end

  defp show_publish_modal(socket, _) do
    socket
    |> assign(:show_publish_modal, false)
  end

  defp show_archive_modal(socket, %{"archive" => _event_id}) do
    socket
    |> assign(:show_archive_modal, true)
  end

  defp show_archive_modal(socket, _) do
    socket
    |> assign(:show_archive_modal, false)
  end
end
