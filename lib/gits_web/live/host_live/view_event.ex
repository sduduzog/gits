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
        assign(socket, :event, event)
        |> assign(:page_title, "Events / #{event.name}")
    end
    |> ok(:host)
  end
end
