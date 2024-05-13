defmodule GitsWeb.EventAddressLive do
  require Ash.Query
  alias Gits.Storefront.Event
  use GitsWeb, :live_view
  import GitsWeb.DashboardComponents

  def mount(params, _session, socket) do
    socket =
      assign(socket, :account_id, params["account_id"])
      |> assign(:event_id, params["event_id"])
      |> assign(:list, [])
      |> assign(:form, %{"query" => nil} |> to_form())

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_event("select_place", unsigned_params, socket) do
    Ash.Query.for_read(Event, :read, %{}, actor: socket.assigns.current_user)
    |> Ash.Query.filter(id: socket.assigns.event_id)
    |> Ash.read_one!()
    |> Ash.Changeset.for_update(:update_address, %{address_place_id: unsigned_params["id"]},
      actor: socket.assigns.current_user
    )
    |> Ash.update!()

    {:noreply,
     redirect(socket,
       to: ~p"/accounts/#{socket.assigns.account_id}/events/#{socket.assigns.event_id}/settings"
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
