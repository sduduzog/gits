defmodule GitsWeb.HostLive.ViewEvent do
  alias Gits.Storefront.Event
  use GitsWeb, :live_view
  require Ash.Query

  embed_templates "view_event_templates/*"

  def mount(_params, _session, socket) do
    case socket.assigns.current_user do
      nil ->
        socket
        |> assign(:page_title, "Events")
        |> ok(:unauthorized)
    end
  end

  def handle_params(%{"public_id" => public_id} = unsigned_params, _uri, socket) do
    Event
    |> Ash.Query.filter(public_id == ^public_id)
    |> Ash.Query.load([:name, :published?])
    |> Ash.read_one()
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:event_published?, event.published?)
        |> assign(:page_title, "Events / #{event.name}")
    end
    |> show_publish_modal(unsigned_params)
    |> show_archive_modal(unsigned_params)
    |> noreply()
  end

  def handle_event("publish", _unsigned_params, socket) do
    %{event_id: event_id} = socket.assigns

    Event.publish_event(event_id)
    |> case do
      {:ok, event} ->
        event |> IO.inspect()
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
