defmodule GitsWeb.HostLive.ViewEvent do
  alias Gits.Accounts.Host
  alias Gits.Storefront.{Event}
  use GitsWeb, :live_view
  require Ash.Query

  embed_templates "view_event_templates/*"

  def mount(params, _session, socket) do
    Ash.Query.for_read(Host, :read, %{}, actor: socket.assigns.current_user)
    |> Ash.Query.load(
      events:
        Ash.Query.filter(Event, public_id == ^params["public_id"])
        |> Ash.Query.load([:unique_views, :total_orders, ticket_types: [:active_tickets_count]])
    )
    |> Ash.read_one()
    |> case do
      {:ok, host} ->
        [event] =
          host.events

        ticket_types = event.ticket_types

        assign(socket, :event, event)
        |> assign(:ticket_types, ticket_types)
        |> assign(:page_title, "Events / #{event.name}")
        |> assign(:section, event.name)
        |> ok(:host)
    end
  end

  def handle_params(_, _, socket) do
    socket |> noreply()
  end

  def handle_event("publish", _, socket) do
    Ash.Changeset.for_update(socket.assigns.event, :publish, %{})
    |> Ash.update(actor: socket.assigns.current_user)
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> noreply()
    end
  end

  def handle_event("archive", _, socket) do
    Ash.Changeset.for_destroy(socket.assigns.event, :destroy)
    |> Ash.destroy(actor: socket.assigns.current_user)

    socket |> noreply()
  end
end
