defmodule GitsWeb.HostLive.EditVenue do
  require Ash.Query
  alias Gits.Accounts.Venue
  alias Gits.Storefront.Event
  alias AshPhoenix.Form
  alias Gits.GooglePlaces
  use GitsWeb, :live_view

  def mount(%{"place" => place_id, "event" => event_id}, _session, socket) do
    {:ok, details} = GooglePlaces.get_place_details(place_id)

    {:ok, event} =
      Ash.Query.filter(Event, public_id == ^event_id)
      |> Ash.Query.load([:venue])
      |> Ash.read_one(actor: socket.assigns.current_user)

    assign(socket, :venue, event.venue)
    |> assign(
      :form,
      Form.for_update(event, :create_venue,
        forms: [auto?: true],
        actor: socket.assigns.current_user
      )
      |> Form.add_form([:venue], params: %{"name" => details.name})
      |> Form.add_form([:venue, :host], type: :read)
    )
    |> assign(
      :details,
      Map.to_list(details) |> Enum.filter(fn {key, _} -> key != :name end)
    )
    |> assign(:name, details.name)
    |> assign(:address, details.address)
    |> assign(:postal_code, details.postal_code)
    |> assign(:place_id, place_id)
    |> assign(:event_id, event_id)
    |> ok(:host_panel)
  end

  def handle_event("validate", unsigned_params, socket) do
    assign(socket, :form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, %{venue: %Venue{}} = event} ->
        assign(socket, :venue, event.venue)
        |> noreply()
    end
  end
end
