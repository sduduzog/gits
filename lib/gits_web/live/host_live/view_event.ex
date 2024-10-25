defmodule GitsWeb.HostLive.ViewEvent do
  alias Gits.Hosts
  alias Gits.Hosts.Event
  alias Gits.Hosts.Host
  use GitsWeb, :host_live_view
  require Ash.Query

  def mount(params, _session, socket) do
    host =
      Host
      |> Ash.Query.filter(handle == ^params["handle"])
      |> Ash.read_first!()

    socket
    |> assign(:host_handle, host.handle)
    |> assign(:host_name, host.name)
    |> assign(:host_logo, host.logo)
    |> ok()
  end

  def handle_params(%{"public_id" => public_id} = unsigned_params, _uri, socket) do
    Event
    |> Ash.Query.filter(public_id == ^public_id)
    |> Ash.Query.load([:name, :details, :published?])
    |> Ash.read_one()
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:event_id, event.id)
        |> assign(:event_public_id, public_id)
        |> assign(:event_name, event.name)
        |> assign(:event_published?, event.published?)
        |> assign(:page_title, "Dashboard - #{event.name}")
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
