defmodule GitsWeb.EventLive.Feature do
  import GitsWeb.EventLive.EventComponents
  use GitsWeb, :live_view
  require Ash.Query

  alias Gits.Storefront.{Basket, Customer, Event, Ticket}

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
        |> ok()
    end
  end

  defp fetch_basket(id, actor) do
    Basket
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id: id)
    |> Ash.Query.load([
      :customer,
      :event_name,
      :instances,
      :total,
      event: [
        :account,
        :masked_id,
        tickets:
          Ticket
          |> Ash.Query.filter(
            sale_starts_at <= fragment("now()") and sale_ends_at > fragment("now()")
          )
      ]
    ])
    |> Ash.read_one(actor: actor)
  end

  def handle_params(%{"basket" => basket_id}, _uri, socket) do
    {:ok, basket} = fetch_basket(basket_id, socket.assigns.current_user)

    socket
    |> assign(:basket, basket)
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket = socket |> assign(:basket, nil)
    {:noreply, socket}
  end

  def handle_event("get_tickets", _unsigned_params, socket) do
    %{event: event, current_user: user} = socket.assigns

    if is_nil(user) do
      push_navigate(socket,
        to: ~p"/sign-in" <> "?return_to=" <> ~p"/events/#{event.masked_id}"
      )
    else
      socket |> open_basket()
    end
    |> noreply()
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    %{
      current_user: user,
      basket: basket
    } = socket.assigns

    basket
    |> Ash.Changeset.for_update(:remove_ticket, %{ticket_id: unsigned_params["id"]}, actor: user)
    |> Ash.update()

    fetch_basket(basket.id, user)
    |> case do
      {:ok, basket} -> socket |> assign(:basket, basket)
      _ -> socket
    end
    |> noreply()
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    %{
      current_user: user,
      basket: basket
    } = socket.assigns

    basket
    |> Ash.Changeset.for_update(:add_ticket, %{ticket_id: unsigned_params["id"]}, actor: user)
    |> Ash.update()

    fetch_basket(basket.id, user)
    |> case do
      {:ok, basket} -> socket |> assign(:basket, basket)
      _ -> socket
    end
    |> noreply()
  end

  def handle_event("checkout", _unsigned_params, socket) do
    %{current_user: user, basket: basket} = socket.assigns

    paid_basket? =
      basket.total
      |> Decimal.gt?("0")

    action =
      if(paid_basket?, do: :start_payment, else: :settle_for_free)

    basket
    |> Ash.Changeset.for_update(action, %{}, actor: user)
    |> Ash.update()
    |> case do
      {:ok, updated_basket} ->
        socket |> assign(:basket, updated_basket)

      _ ->
        socket
    end
    |> noreply()
  end

  def handle_event("cancel_basket", _unsigned_params, socket) do
    %{event: event, current_user: user, basket: basket} = socket.assigns

    with {:ok, _} <- cancel_basket(basket, user) do
      socket |> push_patch(to: ~p"/events/#{event.masked_id}")
    end
    |> noreply()
  end

  def handle_event("close_basket", _unsigned_params, socket) do
    %{event: event} = socket.assigns

    socket
    |> push_patch(to: ~p"/events/#{event.masked_id}")
    |> noreply()
  end

  defp cancel_basket(basket, actor) do
    basket
    |> Ash.Changeset.for_update(:cancel, %{}, actor: actor)
    |> Ash.update()
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

  def render(assigns) do
    ~H"""
    <div
      :if={is_nil(@event.published_at)}
      class="mx-auto w-full max-w-screen-lg rounded-md bg-blue-50 p-4"
    >
      <div class="flex">
        <div class="flex-shrink-0">
          <.icon class="text-blue-400 -mt-1" name="hero-information-circle-mini" />
        </div>
        <div class="ml-3 flex-1 md:flex md:justify-between">
          <p class="text-sm text-blue-700">
            This event is not published
          </p>
          <p :if={false} class="mt-3 text-sm md:mt-0 md:ml-6">
            <a href="#" class="whitespace-nowrap font-medium text-blue-700 hover:text-blue-600">
              Details <span aria-hidden="true"> &rarr;</span>
            </a>
          </p>
        </div>
      </div>
    </div>

    <div class="min-h-96 mx-auto w-full max-w-2xl items-start gap-4 space-y-4 p-2 md:gap-12 md:pt-20 lg:flex lg:max-w-screen-lg lg:space-y-0 lg:p-0">
      <div class="grid gap-2">
        <div class="aspect-[3/2] relative mx-auto shrink-0 overflow-hidden rounded-2xl md:w-96 md:rounded-3xl">
          <.floating_event_date day={@starts_at_day} month={@starts_at_month} />

          <img
            src={@feature_image}
            alt="Event's featured image"
            class="size-full object-cover transition-transform duration-300 hover:scale-110"
          />
        </div>
      </div>
      <div class="grid grow gap-6">
        <h1 class="line-clamp-2 text-2xl font-semibold">
          <%= @event.name %>
        </h1>

        <div class="flex">
          <div class="grow"></div>
          <button
            phx-click="get_tickets"
            class="rounded-xl bg-zinc-800 p-3 px-4 font-medium text-white"
          >
            Get Tickets
          </button>
        </div>
        <div class="space-y-2 rounded-2xl bg-white text-sm">
          <h2 class="font-medium text-zinc-500">About this event</h2>
          <p class="max-w-screen-md whitespace-pre-line"><%= @event.description %></p>
        </div>
      </div>
    </div>

    <.live_component
      :if={not is_nil(@basket)}
      id={@basket.id}
      basket={@basket}
      user={@current_user}
      module={GitsWeb.BasketComponent}
    />
    """
  end
end
