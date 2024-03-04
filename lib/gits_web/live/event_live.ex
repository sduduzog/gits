defmodule GitsWeb.EventLive do
  use GitsWeb, :live_view

  def mount(params, _, socket) do
    socket =
      socket
      |> assign(:event_id, params["id"])
      |> assign(:count, 1)
      |> assign(:tickets, [%{name: "General", price: 50}, %{name: "VIP", price: 250}])
      |> assign(:confirm, true)
      |> assign(:voucher, false)

    {:ok, socket}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_event("inc", _, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count + 1)}
  end

  def handle_event("dec", _, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count - 1)}
  end

  def handle_event("voucher", _, socket) do
    {:noreply, assign(socket, :voucher, !socket.assigns.voucher)}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white min-h-svh">
      <.live_component module={GitsWeb.ComponentsLive.Header} id="1" current_user={@current_user} />
      <div class="max-w-screen-xl mx-auto shrink-0 sm:flex">
        <div class="p-4">
          <div class="aspect-[3/2] sm:w-80 lg:w-auto lg:h-80 bg-gray-200 rounded-2xl overflow-hidden">
            <img src="https://placekitten.com/500/500" class="w-full h-full object-cover" />
          </div>
        </div>
        <div class="grow grid p-4 gap-6 lg:gap-9">
          <h1 class="font-semibold text-2xl line-clamp-4">
            The Ultimate Cheese Event Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          </h1>
          <span class="text-blue-600">Treehouse Inc</span>
          <div class="flex items-center gap-4">
            <div class="px-3 py-2 bg-gray-200 grid leading-4 text-center rounded-xl">
              <span class="tabular-nums font-semibold">29</span>
              <span class="text-xs">Mar</span>
            </div>

            <div class="grow grid text-gray-600">
              <span>10:00 PM</span>
              <span class="truncate">Mea Culpa, 11th Road, Kew, Johannesburg, South Africa</span>
            </div>
          </div>
          <div class="space-y-2 sm:order-last">
            <p class="text-gray-500 text-sm whitespace-pre-line">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Arcu cursus vitae congue mauris rhoncus. Auctor eu augue ut lectus arcu bibendum. Quisque id diam vel quam elementum. Senectus et netus et malesuada. Cursus eget nunc scelerisque viverra mauris in. Quam lacus suspendisse faucibus interdum. Augue interdum velit euismod in pellentesque. Vitae congue eu consequat ac felis donec et. Ac tincidunt vitae semper quis. Viverra vitae congue eu consequat ac.
            </p>
          </div>
          <div class="flex md:flex-row-reverse justify-between md:justify-end gap-4 bg-white sticky bottom-0 inset-x-0 py-4 md:p-0 md:static shadow-sm sm:shadow-none">
            <div class="">
              <span class="text-gray-600">From</span>
              <span class="text-lg font-semibold"> R 250</span>
            </div>
            <button
              phx-click={GitsWeb.CoreComponents.show_modal("get-tickets-modal")}
              type="button"
              class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
            >
              Get Tickets
            </button>
          </div>
        </div>
        <.modal id="get-tickets-modal">
          <div :if={@confirm} class="grid gap-4 ">
            <h2 class="text-lg font-semibold">Your summary</h2>
            <div class="grid gap-4 md:grid-cols-2">
              <div class="border p-4 rounded-xl grid gap-4">
                <div :for={ticket <- @tickets} class="flex justify-between items-center">
                  <span class="text-gray-500 text-sm font-medium">1&times; <%= ticket.name %></span>
                  <span class="font-medium text-gray-700">R <%= ticket.price %></span>
                </div>
                <hr />
                <div class="flex justify-between items-center">
                  <span class="text-gray-600 font-medium">Total</span>
                  <span class="text-lg font-semibold">R 300</span>
                </div>
              </div>
              <div class="">
                <div class="relative">
                  <input
                    type="text"
                    class="block w-full p-4 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                    placeholder="Voucher Code"
                    required
                    disabled={@voucher}
                  />
                  <button
                    phx-click="voucher"
                    type="button"
                    class="text-white absolute end-2.5 bottom-2.5 bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
                  >
                    <%= if @voucher do
                      "Remove"
                    else
                      "Apply"
                    end %>
                  </button>
                </div>
              </div>
            </div>
            <div class="flex justify-end gap-2 items-center">
              <!-- <span class="text-gray-500">R 350</span> -->
              <button
                type="button"
                phx-click={JS.navigate(~p"/events/#{@event_id}/payment")}
                class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
              >
                Pay
              </button>
            </div>
          </div>
          <div :if={!@confirm} class="grid gap-4">
            <h2 class="text-lg font-semibold">Get tickets</h2>
            <div class="grid gap-6 md:grid-cols-2">
              <div
                :for={ticket <- @tickets}
                class="flex sm:border rounded-xl sm:p-2 justify-end items-center gap-2"
              >
                <span class="grow"><%= ticket.name %></span>
                <span class="font-semibold">R <%= ticket.price %></span>
                <div class="flex items-center bg-gray-100 rounded-lg">
                  <button class="p-2 flex rounded-l-lg">
                    <.icon name="hero-minus-mini" />
                  </button>
                  <span class="tabular-nums w-7 text-center">
                    <%= (ticket.price / 10) |> round %>
                  </span>
                  <button class="p-2 flex rounded-r-lg">
                    <.icon name="hero-plus-mini" />
                  </button>
                </div>
              </div>
            </div>

            <div class="flex justify-end gap-2 items-center">
              <span class="text-gray-500">R 350</span>
              <button
                type="button"
                phx-click="confirm"
                class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
              >
                Continue
              </button>
            </div>
          </div>
        </.modal>
      </div>
    </div>
    """
  end
end
