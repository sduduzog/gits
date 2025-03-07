defmodule GitsWeb.BasketComponent do
  use GitsWeb, :live_component

  alias Gits.Currency

  def update(assigns, socket) do
    socket
    |> assign(:id, assigns.id)
    |> assign(:basket, assigns.basket)
    |> assign(:user, assigns.user)
    |> assign(:show_summary, false)
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="bg-zinc-500/50 fixed inset-0 z-20 flex justify-end md:p-2 lg:p-4">
      <div class="grid w-full max-w-screen-md overflow-hidden bg-white md:grid-cols-2 md:rounded-2xl">
        <.reclaimed :if={@basket.state == :reclaimed} basket={@basket} />
        <.cancelled :if={@basket.state == :cancelled} basket={@basket} />
        <.ticket_selection
          :if={@basket.state == :open}
          event_name={@basket.event_name}
          basket_total={@basket.total}
          tickets={@basket.event.tickets}
          instances={@basket.instances}
          not_confirmed={is_nil(@user.confirmed_at)}
        />
        <.payment :if={@basket.state == :payment_started} basket={@basket} user={@user} />
        <.order_completed :if={
          @basket.state == :settled_for_free or @basket.state == :settled_for_payment
        } />
      </div>
    </div>
    """
  end

  def reclaimed(assigns) do
    ~H"""
    <div class="col-span-full flex flex-col items-center justify-center gap-8">
      <span class="text-sm text-zinc-500">reclaimed</span>
      <button
        class="min-w-32 rounded-xl p-4 text-sm font-medium hover:bg-zinc-50"
        phx-click="close_basket"
      >
        Close
      </button>
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

  defp count_tickets(instances, ticket_id) do
    instances |> Enum.count(fn instance -> instance.ticket_id == ticket_id end)
  end

  def ticket_selection(assigns) do
    ~H"""
    <div class="flex flex-col overflow-auto">
      <div class="sticky top-0 md:hidden">
        <.basket_header event_name={@event_name} />
      </div>
      <div class="grid grow content-start gap-4 p-4">
        <div :for={ticket <- @tickets} class="rounded-xl border border-zinc-200 p-2">
          <div class="flex w-full items-center justify-between">
            <span class="p-2 px-4 text-sm font-medium text-zinc-500">
              <span :if={ticket.price |> Decimal.gt?(0)}>
                R <%= ticket.price |> Decimal.mult(count_tickets(@instances, ticket.id)) %>
              </span>
            </span>
            <div class="flex items-center gap-2">
              <button
                class="flex rounded-lg p-4 hover:bg-zinc-100 lg:p-2"
                phx-click="remove_ticket"
                phx-value-id={ticket.id}
              >
                <.icon name="hero-minus-mini" />
              </button>
              <span class="w-6 text-center tabular-nums leading-5">
                <%= count_tickets(@instances, ticket.id) %>
              </span>
              <button
                class="flex rounded-lg p-4 hover:bg-zinc-100 lg:p-2"
                phx-click="add_ticket"
                phx-value-id={ticket.id}
              >
                <.icon name="hero-plus-mini" />
              </button>
            </div>
          </div>
          <div class="p-2 px-4">
            <h3 class="text-xl font-medium">
              <%= ticket.name %>
            </h3>
          </div>
          <div class="flex justify-end p-2 px-4">
            <span :if={ticket.sold_out?} class="grow text-xs text-zinc-500">Sold out</span>
            <span :if={ticket.sold_out_for_actor?} class="grow text-xs text-zinc-500">
              Sold out for you.
            </span>
            <span class="text-xs font-medium text-zinc-800">
              <%= if Decimal.gt?(ticket.price, 0) do %>
                R <%= ticket.price |> Gits.Currency.format() %>
              <% else %>
                FREE
              <% end %>
            </span>
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
        instances={@instances}
        tickets={
          @tickets
          |> Enum.filter(fn ticket -> count_tickets(@instances, ticket.id) > 0 end)
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
          :if={not @not_confirmed}
          class="col-start-2 rounded-xl bg-zinc-900 px-4 py-3 text-sm font-medium text-white"
          phx-click="checkout"
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
      <span class="font-semibold">Payment Process not complete</span>
      <span class="mx-auto w-full max-w-lg px-4 text-center text-sm text-zinc-500">
        There was an issue with your payment. Please review your purchase and try the payment again.
      </span>
      <div class="w-full space-y-4 px-2">
        <div class="mx-auto w-full max-w-lg rounded-lg border *:text-sm">
          <span class="inline-block px-4 pt-4">Summary</span>
          <.basket_summary
            basket_total={@basket.total}
            instances={@basket.instances}
            tickets={
              @basket.event.tickets
              |> Enum.filter(fn ticket -> count_tickets(@basket.instances, ticket.id) > 0 end)
            }
          />
        </div>
        <div class="mx-auto flex w-full max-w-lg gap-4 text-sm font-medium">
          <.link
            class="font-medium py-3 px-4 grow text-center rounded-xl bg-zinc-800 text-white"
            navigate={@basket.paystack_authorization_url}
          >
            Retry payment
          </.link>

          <button phx-click="cancel_basket" class="shrink-0 rounded-xl px-4 py-3 hover:bg-zinc-100">
            Cancel purchase
          </button>
        </div>
      </div>
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
      <button class="flex rounded-xl p-2 hover:bg-zinc-100" phx-click="cancel_basket">
        <.icon name="hero-x-mark-mini" />
      </button>
    </div>
    """
  end

  def basket_summary(assigns) do
    ~H"""
    <div class="p-2 px-4">
      <div :for={ticket <- @tickets} class="flex justify-between py-2 text-zinc-700">
        <span>
          R <%= ticket.price
          |> Decimal.mult(count_tickets(@instances, ticket.id))
          |> Currency.format() %>
        </span>
        <span class="tabular-nums">
          <%= ticket.name %> &times; <%= count_tickets(@instances, ticket.id) %>
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
