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
    |> Ash.Query.load([:name])
    |> Ash.read(actor: socket.assigns.current_user)
    |> case do
      {:ok, events} -> socket |> assign(:events, events)
    end
    |> noreply()
  end

  defp list_event_query(:drafts, _) do
    Event
    |> Ash.Query.filter(is_nil(published_at))
  end

  defp list_event_query(:all, params) do
    Event
    |> Ash.Query.filter(host.handle == ^params["handle"])
  end

  defp list_event_query(_, _) do
    Event
    |> Ash.Query.filter(not is_nil(published_at))
  end
end
