defmodule GitsWeb.HomeLive.Index do
  use GitsWeb, :live_view

  def handle_event("go_to_wizard", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/get-started")}
  end

  def render(assigns) do
    assigns =
      assigns
      |> assign(:events, [%{id: 1}, %{id: 2}])

    ~H"""
    <.live_component module={GitsWeb.ComponentsLive.Header} id="1" current_user={@current_user} />
    <div class="mt-4 gap-4 flex max-w-screen-2xl p-2 overflow-x-auto mx-auto lg:overflow-visible lg:flex-wrap lg:gap-9 xl:gap-14">
      <.link
        :for={event <- @events}
        navigate={~p"/events/#{event.id}"}
        class="rounded-2xl overflow-hidden w-64 aspect-[4/5] relative shrink-0"
        id={"#{event.id}"}
      >
        <img
          src="https://placekitten.com/500/500"
          class="w-full h-full object-cover hover:scale-110 transition-transform duration-300"
        />
        <div class="absolute top-3 right-3 bg-white grid leading-4 py-2 px-3 rounded-lg">
          <span class="font-bold text-gray-800 tabular-nums">29</span>
          <span class="text-xs text-gray-600">Mar</span>
        </div>

        <div class="absolute bottom-3 inset-x-3 bg-white rounded-lg p-2 space-y-2">
          <h3 class="line-clamp-2 text-sm font-semibold">The Ultimate Cheese Festival</h3>
          <div class="flex justify-between items-center">
            <span class="text-gray-600 text-sm">Mea Culpa</span>
            <span class="bg-blue-100 text-blue-800 text-xs font-medium px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300">
              R 300
            </span>
          </div>
        </div>
      </.link>
    </div>
    <div class="py-36 bg-white px-4 mt-12">
      <div class="mx-auto max-w-screen-2xl space-y-6">
        <h2 class="font-bold text-3xl">
          Need to sell tickets for your next event?
          <br />Get started by creating an organiztion with us
        </h2>
        <button
          phx-click="go_to_wizard"
          type="button"
          class="px-5 py-3 text-base font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        >
          Get started
        </button>
      </div>
    </div>
    """
  end
end
