defmodule GitsWeb.EventLive.Feature do
  require Decimal
  import GitsWeb.EventLive.EventComponents
  alias Gits.Currency
  use GitsWeb, :live_view
  require Ash.Query

  alias Gits.Storefront.{Basket, Customer, Event, Ticket}

  def ticket_dates_from_event(%Event{local_starts_at: starts_at, local_ends_at: ends_at}) do
    "#{starts_at |> format_datetime()} - #{ends_at |> format_end_date(starts_at)}"
  end

  defp format_time(starts_at) do
    starts_at |> Timex.format!("%I:%M %p", :strftime)
  end

  defp format_datetime(starts_at) do
    starts_at |> Timex.format!("%A %e %b, %I:%M%p", :strftime)
  end

  defp format_end_date(ends_at, starts_at) do
    starts_at
    |> NaiveDateTime.diff(ends_at, :day)
    |> case do
      0 ->
        ends_at |> format_time()

      _ ->
        ends_at |> format_datetime()
    end
  end

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    Event
    |> Ash.Query.for_read(:read, %{masked_id: params["id"]}, actor: user)
    |> Ash.Query.load([:masked_id, :minimum_ticket_price, :maximum_ticket_price, :host, :address])
    |> Ash.read_one()
    |> case do
      {:ok, nil} ->
        raise GitsWeb.Exceptions.NotFound, "no event found"

      {:error, _} ->
        raise GitsWeb.Exceptions.NotFound, "forbidden"

      {:ok, event} ->
        starts_at_day = event.starts_at |> Timex.format!("%e", :strftime)
        starts_at_month = event.starts_at |> Timex.format!("%b", :strftime)

        socket =
          socket
          |> assign(
            :feature_image,
            Gits.Bucket.get_feature_image_path(event.account_id, event.id)
          )
          |> assign(:event, event)
          |> assign(:basket, nil)
          |> assign(:page_title, event.name)
          |> assign(:event_name, event.name)
          |> assign(:starts_at_day, starts_at_day)
          |> assign(:starts_at_month, starts_at_month)

        if FunWithFlags.enabled?(:beta, for: user) do
          {:ok, socket, layout: false, temporary_assigns: [{SEO.key(), nil}]}
        else
          {:ok, socket, layout: {GitsWeb.Layouts, :event}, temporary_assigns: [{SEO.key(), nil}]}
        end
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
          |> Ash.Query.filter(availability in [:public, :open])
          |> Ash.Query.load([
            :sold_out?,
            :sold_out_for_actor?,
            :total_sold
          ])
      ]
    ])
    |> Ash.read_one(actor: actor)
  end

  def handle_params(%{"basket" => basket_id}, _uri, socket) do
    fetch_basket(basket_id, socket.assigns.current_user)
    |> case do
      {:ok, basket} ->
        socket |> assign(:basket, basket) |> SEO.assign(socket.assigns.event) |> noreply()

      {:error, _} ->
        raise GitsWeb.Exceptions.NotFound, "no basket found"
    end
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket = socket |> assign(:basket, nil)
    socket |> SEO.assign(socket.assigns.event) |> noreply()
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
    |> Ash.Query.filter(
      state not in [:cancelled, :reclaimed, :settled_for_free, :settled_for_payment]
    )
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
    <%= if FunWithFlags.enabled?(:beta, for: @current_user) do %>
      <div class="grid flex-wrap gap-1 md:grid-cols-[auto_1fr] md:gap-8 md:p-4 lg:mx-auto lg:max-w-screen-lg">
        <div class="absolute top-2 left-2 col-span-full flex md:static">
          <.link
            navigate={~p"/search"}
            class="bg-white/20 rounded-xl p-3 backdrop-blur-md dark:bg-black/10"
          >
            <.icon name="hero-chevron-left" />
          </.link>
        </div>
        <div class="aspect-[3/2] shrink-0 md:w-72 md:overflow-hidden md:rounded-2xl lg:w-96">
          <img
            loading="eager"
            src={Gits.Bucket.get_feature_image_path(@event.account_id, @event.id)}
            alt="Event's featured image"
            class="size-full object-cover md:transition-transform md:duration-300 md:hover:scale-110"
          />
        </div>
        <div class="space-y-3 p-2 md:mx-auto md:w-full md:space-y-4 md:p-0 lg:space-y-6">
          <h1 class="line-clamp-2 text-2xl font-semibold leading-tight">
            <%= @event.name %>
          </h1>
          <span class="text-xs font-medium text-zinc-500 dark:border-zinc-600 dark:text-zinc-400">
            <%= @event.host %>
          </span>
          <div class="flex gap-2">
            <.icon name="hero-calendar-days-mini" class="shrink-0 text-zinc-500 dark:text-zinc-400" />
            <span class="font-medium leading-tight text-zinc-800 dark:text-zinc-200">
              <%= ticket_dates_from_event(@event) %>
            </span>
          </div>
          <div class="flex items-start gap-2">
            <.icon name="hero-map-pin-mini" class="shrink-0  text-zinc-500 dark:text-zinc-400" />
            <div class="grid">
              <span class="font-medium leading-tight text-zinc-800 dark:text-zinc-200">
                <%= @event.address.display_name %>
              </span>
              <span class="text-xs text-zinc-500 dark:text-zinc-400">
                <%= @event.address.short_format_address %>
              </span>
            </div>
          </div>
          <div class="flex gap-2">
            <.icon name="hero-ticket-mini" class="shrink-0 text-zinc-500 dark:text-zinc-400" />
            <span class="font-medium leading-tight text-zinc-800 dark:text-zinc-200">
              <%= resolve_price_range_label(@event) %>
            </span>
          </div>
        </div>
      </div>
      <div class="flex bg-white p-4 dark:bg-zinc-900 lg:mx-auto lg:max-w-screen-lg">
        <span class="rounded-xl border px-2 py-1 text-xs font-medium text-zinc-800 dark:border-zinc-600 dark:text-zinc-200">
          <%= @event.host %>
        </span>
      </div>
      <div class="flex items-center justify-between p-4 md:gap-8 lg:mx-auto lg:max-w-screen-lg">
        <div class="flexx hidden items-center">
          <span class="text-sm">You have 2 tickets</span>
          <span class="px-2 py-1 text-sm font-medium underline">view</span>
        </div>
        <button
          class="max-w-40 w-full rounded-lg bg-zinc-800 px-4 py-3 text-sm font-medium text-white active:bg-zinc-700"
          phx-click="get_tickets"
        >
          Get Tickets
        </button>
      </div>
      <div class="space-y-2 p-4 text-sm lg:mx-auto lg:max-w-screen-lg">
        <h2 class="font-medium text-zinc-500 dark:text-zinc-400">About this event</h2>
        <p class="max-w-screen-md whitespace-pre-line"><%= @event.description %></p>
      </div>
    <% else %>
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
              loading="eager"
              src={@feature_image}
              alt="Event's featured image"
              class="size-full object-cover transition-transform duration-300 hover:scale-110"
            />
          </div>
        </div>
        <div class="grid grow">
          <h1 class="line-clamp-2 text-2xl font-semibold">
            <%= @event.name %>
          </h1>
          <div class="flex justify-between text-sm text-zinc-500">
            <span>
              by <%= @event.host %>
            </span>
          </div>

          <div class="flex items-center py-6">
            <div class="grow">
              <span class=" font-medium text-zinc-700">
                <%= resolve_price_range_label(@event) %>
              </span>
            </div>
            <button
              phx-click="get_tickets"
              class="rounded-xl bg-zinc-800 p-3 px-4 font-medium text-white"
            >
              Get Tickets
            </button>
          </div>

          <%= if not is_nil(@event.address) do %>
            <div class="flex gap-2 rounded-xl border p-4">
              <.icon name="hero-map-pin-micro" class="shrink-0 mt-0.5" />
              <.link
                class="flex grow flex-wrap items-center justify-between gap-x-1 gap-y-2 text-sm text-zinc-500"
                target="_blank"
                href={@event.address.google_maps_uri}
              >
                <span><%= @event.address.display_name %> &bull; <%= @event.address.city %></span>
                <span class="text-xs text-zinc-400">Click for directions</span>
              </.link>
            </div>
          <% end %>
          <div class="mt-4 space-y-2 rounded-2xl bg-white text-sm">
            <div class="flex items-center justify-between">
              <h2 class="font-medium text-zinc-500">About this event</h2>
              <span class="text-sm text-zinc-500"><%= ticket_dates_from_event(@event) %></span>
            </div>
            <p class="max-w-screen-md whitespace-pre-line"><%= @event.description %></p>
          </div>
        </div>
      </div>
    <% end %>
    <.live_component
      :if={not is_nil(@basket)}
      id={@basket.id}
      basket={@basket}
      user={@current_user}
      module={GitsWeb.BasketComponent}
    />
    """
  end

  defp resolve_min_price_label(price) do
    if Decimal.eq?(price, 0) do
      "FREE"
    else
      "R#{price |> Currency.format()}"
    end
  end

  defp resolve_price_range_label(%Event{minimum_ticket_price: min, maximum_ticket_price: max}) do
    if min == max do
      "#{resolve_min_price_label(min)}"
    else
      "#{resolve_min_price_label(min)} - R#{max |> Currency.format()}"
    end
  end
end
