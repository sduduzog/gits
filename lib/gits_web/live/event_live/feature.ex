defmodule GitsWeb.EventLive.Feature do
  alias Gits.Workers.Basket
  use GitsWeb, :live_view
  require Ash.Query

  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    Event
    |> Ash.Query.for_read(:read, %{masked_id: params["id"]}, actor: user)
    |> Ash.Query.load(:masked_id)
    |> Ash.read_one()
    |> case do
      {:ok, nil} ->
        raise GitsWeb.Exceptions.NotFound, "no event found"

      {:error, _} ->
        raise GitsWeb.Exceptions.NotFound, "forbidden"

      {:ok, event} ->
        local_starts_at =
          event.starts_at
          |> Timex.local()

        starts_at_day = local_starts_at |> Timex.format!("%e", :strftime)
        starts_at_month = local_starts_at |> Timex.format!("%b", :strftime)

        socket
        |> assign(
          :feature_image,
          Gits.Bucket.get_feature_image_path(event.account_id, event.id)
        )
        |> assign(:event, event)
        |> assign(:event_name, event.name)
        |> assign(:starts_at_day, starts_at_day)
        |> assign(:starts_at_month, starts_at_month)
        |> assign(:show_basket_modal, false)
        |> assign(:basket_id, nil)
        |> ok()
    end
  end

  def handle_params(unsigned_params, _uri, socket) do
    socket = socket |> assign(:basket_id, unsigned_params["basket"])
    {:noreply, socket}
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

  def handle_event("close_basket", _unsigned_params, socket) do
    event = socket.assigns.event

    socket = socket |> push_patch(to: ~p"/events/#{event.masked_id}")
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

    with {:ok, nil} <- find_existing_basket(event.id, customer.id, user),
         {:ok, new_basket} <- create_new_basket(event, customer, user) do
      push_patch(socket, to: ~p"/events/#{event.masked_id}/?basket=#{new_basket.id}")
    else
      {:ok, existing_basket} ->
        push_patch(socket, to: ~p"/events/#{event.masked_id}/?basket=#{existing_basket.id}")

      :create_error ->
        socket
    end
  end

  defp find_existing_basket(event_id, customer_id, actor) do
    Basket
    |> Ash.Query.for_read(:read, %{}, actor: actor)
    |> Ash.Query.filter(state == :open)
    |> Ash.Query.filter(event.id == ^event_id)
    |> Ash.Query.filter(customer.id == ^customer_id)
    |> Ash.Query.limit(1)
    |> Ash.read_one()
  end

  defp create_new_basket(event, customer, actor) do
    Basket
    |> Ash.Changeset.for_create(:open_basket, %{event: event, customer: customer}, actor: actor)
    |> Ash.create()
    |> case do
      {:ok, basket} -> {:ok, basket}
      _ -> :create_error
    end
  end
end
