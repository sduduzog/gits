defmodule GitsWeb.EventLive.Feature do
  use GitsWeb, :live_view

  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    event =
      Ash.Query.for_read(Event, :for_feature, %{id: params["id"]}, actor: user)
      |> Ash.read_one!()

    local_starts_at =
      event.starts_at
      |> Timex.local()

    starts_at_day = local_starts_at |> Timex.format!("%e", :strftime)
    starts_at_month = local_starts_at |> Timex.format!("%b", :strftime)

    socket =
      socket
      |> assign(:feature_image, Gits.Bucket.get_feature_image_path(event.account_id, event.id))
      |> assign(:event, event)
      |> assign(:event_name, event.name)
      |> assign(:starts_at_day, starts_at_day)
      |> assign(:starts_at_month, starts_at_month)

    {:ok, socket, layout: {GitsWeb.Layouts, :next}}
  end

  def handle_event("get_tickets", _unsigned_params, socket) do
    user =
      socket.assigns.current_user

    event = socket.assigns.event

    socket =
      if is_nil(user) do
        push_navigate(socket,
          to: ~p"/sign-in" <> "?return_to=" <> ~p"/events/#{event.masked_id}"
        )
      else
        socket |> open_basket()
      end

    {:noreply, socket}
  end

  defp open_basket(socket) do
    user =
      socket.assigns.current_user

    event = socket.assigns.event

    customer =
      Customer
      |> Ash.Changeset.for_create(:create, %{user: user}, actor: user)
      |> Ash.create!()

    basket =
      Basket
      |> Ash.Changeset.for_create(:open_basket, %{event: event, customer: customer}, actor: user)
      |> Ash.create!()

    push_navigate(socket, to: ~p"/events/#{event.masked_id}/tickets/#{basket.id}")
  end
end
