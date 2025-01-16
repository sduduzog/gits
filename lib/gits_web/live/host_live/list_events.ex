defmodule GitsWeb.HostLive.ListEvents do
  alias Gits.Storefront.Event
  require Ash.Query
  use GitsWeb, :live_view

  require Ash.Query

  def mount(_params, _session, socket) do
    case socket.assigns.current_user do
      nil ->
        socket
        |> assign(:page_title, "Unauthorized")
        |> ok(:unauthorized)

      _ ->
        socket
        |> assign(:page_title, "Events")
        |> ok(:host)
    end
  end

  def handle_params(unsigned_params, _, socket) do
    list_event_query(socket.assigns.live_action, unsigned_params)
    |> Ash.Query.filter(host.handle == ^unsigned_params["handle"])
    |> Ash.Query.load([:name])
    |> Ash.read(actor: socket.assigns.current_user)
    |> case do
      {:ok, events} -> socket |> assign(:events, events)
    end
    |> noreply()
  end

  defp list_event_query(:archived, _) do
    Event
    |> Ash.Query.for_read(:archived)
  end

  defp list_event_query(:drafts, _) do
    Event
    |> Ash.Query.filter(state == :draft)
  end

  defp list_event_query(:completed, _params) do
    Event
    |> Ash.Query.filter(state == :completed)
  end

  defp list_event_query(:all, _params) do
    Event
  end

  defp list_event_query(:published, _) do
    Event
    |> Ash.Query.filter(state == :published)
  end
end
