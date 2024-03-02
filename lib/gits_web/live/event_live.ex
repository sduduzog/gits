defmodule GitsWeb.EventLive do
  use GitsWeb, :live_view

  def mount(params, _, socket) do
    {:ok, assign(socket, :event_id, params["id"])}
  end

  def render(assigns) do
    IO.inspect(assigns)

    ~H"""
    <div class="bg-white min-h-svh">
      <div class="p-2 max-w-screen-2xl mx-auto">
        <button class="p-2">
          <.icon name="hero-arrow-left" />
        </button>
      </div>
      <div class="max-w-screen-2xl mx-auto shrink-0 sm:flex">
        <div class="p-4">
          <div class="aspect-[3/2] sm:w-80 lg:w-auto lg:h-80 bg-gray-200 rounded-2xl"></div>
        </div>
        <div class="grow grid p-4 gap-6 lg:gap-9">
          <h1 class="font-semibold text-2xl">The Ultimate Cheese Event</h1>
          <div class="flex items-center gap-4">
            <div class="px-3 py-2 bg-gray-200 grid leading-4 text-center rounded-xl">
              <span class="tabular-nums font-semibold">29</span>
              <span class="text-xs">Mar</span>
            </div>

            <div class="grow"></div>
            <button
              type="button"
              class="py-3 px-3 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-100 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700"
            >
              <.icon name="hero-map-pin" />
            </button>
          </div>
          <div class="flex items-center justify-between md:justify-end gap-4">
            <span class="text-gray-500">hosted by</span>
            <span class="text-blue-600">Treehouse Inc</span>
          </div>
          <div class="space-y-2 sm:order-last">
            <h2 class="text-lg font-semibold">About this event</h2>
            <p class="text-gray-500 text-sm whitespace-pre-line">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Arcu cursus vitae congue mauris rhoncus. Auctor eu augue ut lectus arcu bibendum. Quisque id diam vel quam elementum. Senectus et netus et malesuada. Cursus eget nunc scelerisque viverra mauris in. Quam lacus suspendisse faucibus interdum. Augue interdum velit euismod in pellentesque. Vitae congue eu consequat ac felis donec et. Ac tincidunt vitae semper quis. Viverra vitae congue eu consequat ac.
            </p>
          </div>
          <div class="flex justify-between md:justify-end gap-4 bg-white sticky bottom-0 inset-x-0 py-4 md:p-0 md:static shadow-sm sm:shadow-none">
            <div class="">
              <span class="text-gray-600">From</span>
              <span class="text-lg font-semibold"> R 250</span>
            </div>
            <button
              type="button"
              class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
            >
              Get Tickets
            </button>
          </div>
        </div>
        <.modal
          on_cancel={JS.navigate(~p"/events/#{@event_id}")}
          show={@live_action == :get_tickets}
          id="get-tickets-modal"
        >
        </.modal>
        <%= if @live_action == :get_tickets do %>
          <div class="p-4 bg-gray-200">
            Get tickets
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
