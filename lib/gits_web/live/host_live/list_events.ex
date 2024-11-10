defmodule GitsWeb.HostLive.ListEvents do
  alias Gits.Storefront.Event
  alias Gits.Hosting.Host
  require Ash.Query
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
    |> assign(:page_title, "Events")
    |> ok()
  end

  def handle_params(unsigned_params, _, socket) do
    list_event_query(socket.assigns.live_action, unsigned_params)
    |> Ash.Query.load([:name])
    |> Ash.read()
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
