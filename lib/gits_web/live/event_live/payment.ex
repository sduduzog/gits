defmodule GitsWeb.EventLive.Payment do
  use GitsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <button class="text-gray-600 p-1" phx-click={JS.navigate(~p"/", replace: true)}>
        <.icon name="hero-x-mark" />
      </button>
    </div>
    <div class="py-4 flex flex-col pt-32 gap-12 items-center">
      <div class="overflow-hidden rounded-full w-52 aspect-square p-4 bg-gray-300 mx-auto">
        <img src="/images/order_complete.jpeg" class="rounded-full" />
      </div>
      <div class="w-64 space-y-2 text-center">
        <h1 class="font-bold text-2xl">Order Complete</h1>
        <p class="text-gray-600">Your order was successful! see you at the event</p>
      </div>
      <button
        phx-click={JS.navigate(~p"/tickets")}
        class="px-28 py-3.5 text-base font-medium text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 rounded-lg text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      >
        View tickets
      </button>
    </div>
    """
  end
end