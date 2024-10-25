defmodule GitsWeb.StorefrontLive.EventListing do
  alias Gits.Hosts.Event
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    Event.get_by_public_id_for_listing(params["public_id"])
    |> case do
      {:ok, event} -> socket |> assign(:event_name, event.name)
    end
    |> ok()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket |> noreply()
  end
end
