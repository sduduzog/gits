defmodule GitsWeb.EventAddressLive do
  require Ash.Query
  use GitsWeb, :live_view
  import GitsWeb.DashboardComponents
  alias Gits.Dashboard

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:list, [])
      |> assign(:account_id, params["account_id"])
      |> assign(:event_id, params["event_id"])
      # |> assign(:place_id, nil)
      |> assign(:form, %{"query" => nil} |> to_form())

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_params(unsigned_params, _uri, socket) do
    case Dashboard.fetch_address_from_api(unsigned_params["place_id"]) do
      {:ok, address} ->
        {:noreply, assign(socket, :address, address)}

      {:error, _} ->
        {:noreply, assign(socket, :address, nil)}
    end
  end

  def handle_event("select_address", unsigned_params, socket) do
    {:noreply,
     push_patch(socket,
       to:
         ~p"/accounts/#{socket.assigns.account_id}/events/#{socket.assigns.event_id}/address?place_id=#{unsigned_params["id"]}"
     )}
  end

  def handle_event("search", unsigned_params, socket) do
    if unsigned_params["query"] == "" do
      {:noreply, socket}
    else
      {:noreply,
       assign(socket, :list, Gits.Dashboard.search_for_address!(unsigned_params["query"]))}
    end
  end
end
