defmodule GitsWeb.BasketComponent do
  use GitsWeb, :live_component

  alias Gits.Currency
  alias Gits.Storefront.Basket
  alias Gits.Storefront.Ticket

  def update(assigns, socket) do
    basket =
      Basket
      |> Ash.get!(assigns.id, actor: assigns.user)

    tickets =
      Ticket
      |> Ash.Query.for_read(:read, %{}, actor: assigns.user)
      |> Ash.Query.load(
        customer_reserved_instance_count_for_basket: [basket_id: basket.id],
        customer_reserved_instance_price_for_basket: [basket_id: basket.id]
      )
      |> Ash.read!()

    socket =
      socket
      |> assign(:id, assigns.id)
      |> assign(:user, assigns.user)
      |> assign(:basket, basket)
      |> assign(:tickets, tickets)
      |> assign(:show_summary, false)

    {:ok, socket}
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    %{
      tickets: tickets,
      user: user,
      basket: basket
    } = socket.assigns

    ticket =
      Enum.find(tickets, fn ticket -> ticket.id == unsigned_params["id"] end)

    socket =
      basket.instances
      |> Enum.filter(fn x -> x.ticket_id == ticket.id end)
      |> Enum.sort(&(&1.id < &2.id))
      |> case do
        [instance | _] ->
          updated_ticket =
            ticket
            |> Ash.Changeset.for_update(:remove_instance, %{instance: instance}, actor: user)
            |> Ash.update!()
            |> Ash.load!(
              [
                customer_reserved_instance_count_for_basket: [basket_id: basket.id],
                customer_reserved_instance_price_for_basket: [basket_id: basket.id]
              ],
              actor: user
            )

          updated_tickets = tickets |> swap_stale_ticket_in_list(updated_ticket)

          socket
          |> assign(
            :tickets,
            updated_tickets
          )

        _ ->
          socket
      end

    socket = socket |> assign(:basket, basket |> Ash.reload!(actor: user))

    {:noreply, socket}
  end

  defp swap_stale_ticket_in_list(tickets, updated_ticket) do
    tickets
    |> Enum.map(fn ticket ->
      if(ticket.id == updated_ticket.id, do: updated_ticket, else: ticket)
    end)
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    %{
      tickets: tickets,
      user: user,
      basket: basket
    } = socket.assigns

    updated_ticket =
      Enum.find(tickets, fn ticket -> ticket.id == unsigned_params["id"] end)
      |> Ash.Changeset.for_update(:add_instance, %{instance: %{basket: basket}}, actor: user)
      |> Ash.update!()
      |> Ash.load!(
        [
          customer_reserved_instance_count_for_basket: [basket_id: basket.id],
          customer_reserved_instance_price_for_basket: [basket_id: basket.id]
        ],
        actor: user
      )

    updated_tickets = tickets |> swap_stale_ticket_in_list(updated_ticket)

    socket
    |> assign(
      :tickets,
      updated_tickets
    )

    socket = socket |> assign(:basket, basket |> Ash.reload!(actor: user))

    {:noreply, socket}
  end

  def handle_event("checkout", _unsigned_params, socket) do
    %{user: user, basket: basket} = socket.assigns

    paid_basket? =
      basket.sum_of_instance_prices
      |> Decimal.gt?("0")

    action = if(paid_basket?, do: :start_payment, else: :settle_for_free)

    socket =
      basket
      |> Ash.load!([event: [:account]], actor: user)
      |> Ash.Changeset.for_update(action, %{}, actor: user)
      |> Ash.update()
      |> case do
        {:ok, updated_basket} ->
          socket |> assign(:basket, updated_basket)

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-zinc-500/50 fixed inset-0 z-20 flex justify-end md:p-2 lg:p-4">
      <div class="grid w-full max-w-screen-md overflow-hidden bg-white md:grid-cols-2 md:rounded-2xl">
        <.cancelled :if={@basket.state == :cancelled} basket={@basket} />
        <.ticket_selection
          :if={@basket.state == :open}
          event_name={@basket.event_name}
          basket_total={@basket.sum_of_instance_prices}
          tickets={@tickets}
          myself={@myself}
        />
        <.payment :if={@basket.state == :payment_started} basket={@basket} user={@user} />
        <.order_completed :if={
          @basket.state == :settled_for_free or @basket.state == :settled_for_payment
        } />
      </div>
    </div>
    """
  end

  def cancelled(assigns) do
    ~H"""
    <div class="col-span-full flex flex-col items-center justify-center gap-8">
      <span class="text-sm text-zinc-500">cancelled</span>
      <button
        class="min-w-32 rounded-xl p-4 text-sm font-medium hover:bg-zinc-50"
        phx-click="close_basket"
      >
        Close
      </button>
    </div>
    """
  end

  def loading(assigns) do
    ~H"""
    <div class="col-span-full flex flex-col items-center justify-center gap-8">
      <svg
        class="animate-spin text-zinc-400"
        xmlns="http://www.w3.org/2000/svg"
        width="32"
        height="32"
        viewBox="0 0 24 24"
      >
        <path
          fill="currentColor"
          d="M12 22c5.421 0 10-4.579 10-10h-2c0 4.337-3.663 8-8 8s-8-3.663-8-8c0-4.336 3.663-8 8-8V2C6.579 2 2 6.58 2 12c0 5.421 4.579 10 10 10"
        />
      </svg>
      <%= @basket.state %>
      <span class="text-sm text-zinc-500">thinking...</span>
    </div>
    """
  end

  def ticket_selection(assigns) do
    ~H"""
    <div class="flex flex-col overflow-auto bg-zinc-50 ">
      <div class="sticky top-0 shadow-sm md:hidden">
        <.basket_header event_name={@event_name} />
      </div>
      <div class="grid grow content-start gap-4 p-4">
        <div :for={ticket <- @tickets} class="">
          <div class="space-y-4 rounded-xl bg-white p-2 shadow-sm">
            <div class="flex justify-end">
              <div class="flex items-center gap-2">
                <button
                  class="flex rounded-lg p-2 hover:bg-zinc-100"
                  phx-click="remove_ticket"
                  phx-value-id={ticket.id}
                  phx-target={@myself}
                >
                  <.icon name="hero-minus-mini" />
                </button>
                <span class="w-6 text-center tabular-nums leading-5">
                  <%= ticket.customer_reserved_instance_count_for_basket %>
                </span>
                <button
                  class="flex rounded-lg p-2 hover:bg-zinc-100"
                  phx-click="add_ticket"
                  phx-value-id={ticket.id}
                  phx-target={@myself}
                >
                  <.icon name="hero-plus-mini" />
                </button>
              </div>
            </div>
            <div class="flex justify-between *:p-2 *:font-semibold">
              <span><%= ticket.name %></span>
              <span>R <%= ticket.price |> Gits.Currency.format() %></span>
            </div>
          </div>
        </div>
      </div>
      <div class="sticky bottom-0 grid grid-cols-2 gap-2 bg-white p-2 shadow-sm md:hidden">
        <button
          phx-click={JS.show(to: "#basket_summary", display: "flex")}
          class="col-start-2 rounded-xl bg-zinc-900 px-4 py-3 text-sm font-medium text-white"
        >
          View summary
        </button>
      </div>
    </div>
    <div
      class="absolute inset-0 hidden flex-col bg-white md:static md:flex md:border-r"
      id="basket_summary"
    >
      <div class="grow md:block">
        <.basket_header event_name={@event_name} />
      </div>
      <.basket_summary
        basket_total={@basket_total}
        tickets={
          @tickets
          |> Enum.filter(fn ticket -> ticket.customer_reserved_instance_count_for_basket > 0 end)
        }
      />
      <div class="grid grid-cols-2 gap-2 p-2">
        <button
          class="rounded-xl px-4 py-3 text-sm font-medium ring-1 ring-zinc-200 md:hidden"
          phx-click={JS.hide(to: "#basket_summary")}
        >
          Back to tickets
        </button>
        <button
          class="col-start-2 rounded-xl bg-zinc-900 px-4 py-3 text-sm font-medium text-white"
          phx-click="checkout"
          phx-target={@myself}
        >
          Checkout
        </button>
      </div>
    </div>
    """
  end

  def payment(%{basket: %{payment_method: :paystack, paystack_reference: nil} = basket} = assigns) do
    user = assigns.user

    basket =
      basket
      |> Ash.Changeset.for_update(:start_paystack_transaction, %{}, actor: user)
      |> Ash.update!()

    assigns = assigns |> assign(:basket, basket)

    ~H"""
    <div
      phx-mounted={JS.navigate(@basket.paystack_authorization_url)}
      class="col-span-full flex flex-col items-center justify-center gap-8"
    >
      <span class="font-semibold">Starting payment process...</span>
      <span class="text-sm text-zinc-500">
        If you were not redirected,
        <.link
          class="font-medium underline text-zinc-900"
          navigate={@basket.paystack_authorization_url}
        >
          click here
        </.link>
      </span>
    </div>
    """
  end

  def payment(%{basket: %{payment_method: :paystack} = basket} = assigns) do
    user = assigns.user

    basket =
      basket
      |> Ash.Changeset.for_update(:evaluate_paystack_transaction, %{}, actor: user)
      |> Ash.update!()

    assigns = assigns |> assign(:basket, basket)

    ~H"""
    <div class="col-span-full flex flex-col items-center justify-center gap-8">
      <span class="font-semibold">Started payment process...</span>
      <span class="text-sm text-zinc-500">
        If you were not redirected,
        <.link
          class="font-medium underline text-zinc-900"
          navigate={@basket.paystack_authorization_url}
        >
          click here
        </.link>
      </span>
    </div>
    """
  end

  def payment(assigns) do
    ~H"""
    <div class="col-span-full flex flex-col items-center justify-center gap-8">
      <span class="font-semibold">Starting payment process...</span>
      <span class="text-sm text-zinc-500">If you were not redirected, click here</span>
    </div>
    """
  end

  def order_completed(assigns) do
    ~H"""
    <div class="col-span-full flex flex-col items-center justify-center gap-8">
      <div class="size-16 flex items-center justify-center rounded-full bg-green-100 text-green-600">
        <.icon name="hero-check" class="text-lg" />
      </div>
      <span class="font-semibold">Order successful</span>
      <span class="text-sm text-zinc-500">This is a story of how you got this tickets</span>
      <div class="grid grid-cols-2 gap-4">
        <button
          phx-click={JS.navigate(~p"/my/tickets")}
          class="min-w-32 rounded-xl bg-zinc-100 p-4 text-sm font-medium hover:bg-zinc-200"
        >
          View tickets
        </button>
        <button
          class="min-w-32 rounded-xl p-4 text-sm font-medium hover:bg-zinc-50"
          phx-click="close_basket"
        >
          Close
        </button>
      </div>
    </div>
    """
  end

  def basket_header(assigns) do
    ~H"""
    <div class="flex items-center justify-end bg-white p-4">
      <div class="grid grow">
        <h1 class="text-xl font-semibold"><%= @event_name %></h1>
      </div>
      <button class="flex rounded-xl p-2 hover:bg-zinc-100" phx-click="close_basket">
        <.icon name="hero-x-mark-mini" />
      </button>
    </div>
    """
  end

  def basket_summary(assigns) do
    ~H"""
    <div class="p-2 px-4 ">
      <div :for={ticket <- @tickets} class="flex justify-between py-4 text-zinc-700 *:text-lg">
        <span>R <%= ticket.customer_reserved_instance_price_for_basket |> Currency.format() %></span>
        <span class="tabular-nums">
          <%= ticket.name %> &times; <%= ticket.customer_reserved_instance_count_for_basket %>
        </span>
      </div>
      <div class="flex justify-between border-t pt-4 *:text-lg *:font-medium">
        <span>R <%= @basket_total |> Currency.format() %></span>
        <span>Total</span>
      </div>
    </div>
    """
  end
end
