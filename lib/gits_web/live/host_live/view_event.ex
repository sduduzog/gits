defmodule GitsWeb.HostLive.ViewEvent do
  alias Gits.Storefront.{Event}
  use GitsWeb, :live_view
  require Ash.Query

  embed_templates "view_event_templates/*"

  def mount(params, _session, socket) do
    Ash.Query.filter(Event, public_id == ^params["public_id"])
    |> Ash.Query.load(ticket_types: [:tickets_count])
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, event} ->
        ticket_types =
          Enum.map(event.ticket_types, fn type ->
            tags = if type.check_in_enabled, do: ["RSVP"], else: []

            {type.id, type.name, type.color, type.tickets_count, type.quantity, tags}
          end)

        assign(socket, :event, event)
        |> assign(:ticket_types, ticket_types)
        |> assign(:page_title, "Events / #{event.name}")
    end
    |> ok(:host)
  end
end
