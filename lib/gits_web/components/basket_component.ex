defmodule GitsWeb.BasketComponent do
  use GitsWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:id, assigns.id)
      |> assign(:show_summary, false)
      |> assign(:step, :loading)

    {:ok, socket}
  end

  def handle_event("checkout", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_event("show_summary", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-zinc-500/50 fixed inset-0 z-20 flex justify-end md:p-2 lg:p-4">
      <div class="grid w-full max-w-screen-md overflow-hidden bg-white md:grid-cols-2 md:rounded-2xl">
        <.loading :if={@step == :loading} />
        <.ticket_selection :if={@step == :selection} />
        <.payment :if={@step == :payment} />
        <.order_completed :if={@step == :completed} />
      </div>
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
      <span class="text-sm text-zinc-500">thinking...</span>
    </div>
    """
  end

  def ticket_selection(assigns) do
    ~H"""
    <div class="flex flex-col overflow-auto bg-zinc-50 ">
      <div class="sticky top-0 border-b md:hidden">
        <.basket_header />
      </div>
      <div class="grow">
        <div :for={i <- 1..5}>Ticket <%= i %></div>
      </div>
      <div class="sticky bottom-0 border-t bg-white md:hidden">
        <button phx-click={JS.show(to: "#basket_summary", display: "flex")} class="p-2">
          show summary
        </button>
      </div>
    </div>
    <div
      class="absolute inset-0 hidden flex-col bg-white md:static md:flex md:border-r"
      id="basket_summary"
    >
      <div class="md:block">
        <.basket_header />
      </div>
      <.basket_summary />
      <div class="grow"></div>
      <div class="grid grid-cols-2 gap-2 p-2">
        <button class="md:hidden" phx-click={JS.hide(to: "#basket_summary")}>go back</button>
        <button class="col-start-2">Finish</button>
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
        <button class="min-w-32 rounded-xl bg-zinc-100 p-4 text-sm font-medium hover:bg-zinc-200">
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
    <div class="flex justify-end bg-white p-4 pb-2">
      <button class="flex rounded-xl bg-zinc-200 p-2" phx-click="close_basket">
        <.icon name="hero-x-mark-mini" />
      </button>
    </div>
    """
  end

  def basket_summary(assigns) do
    ~H"""
    <div></div>
    """
  end
end
