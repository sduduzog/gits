defmodule GitsWeb.SearchLive.Index do
  use GitsWeb, :live_view

  def render(assigns) do
    assigns =
      assigns
      |> assign(:events, [%{id: 1}, %{id: 2}, %{id: 3}, %{id: 4}, %{id: 5}, %{id: 6}, %{id: 7}])

    ~H"""
    <.live_component module={GitsWeb.ComponentsLive.Header} id="1" current_user={@current_user} />
    <div class="mt-4 gap-2 max-w-screen-2xl p-2 mx-auto grid md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 xl:gap-6">
      <div :for={event <- @events} class="bg-white rounded-2xl p-2 flex" id={"#{event.id}"}>
        <div class="relative overflow-hidden rounded-xl w-24 aspect-[4/5] shrink-0">
          <img src="https://placekitten.com/500/500" class="w-full h-full object-cover" />
          <div class="absolute top-2 left-2 bg-white grid leading-4 py-2 px-3 rounded-lg ">
            <span class="font-bold text-gray-800 tabular-nums">29</span>
            <span class="text-xs text-gray-600">Mar</span>
          </div>
        </div>

        <div class="p-2 flex flex-col justify-between space-y-2 w-full">
          <h3 class="line-clamp-3 text-sm font-semibold">The Ultimate Cheese Festival</h3>
          <div class="flex justify-between items-center">
            <span class="text-gray-600 text-sm">Mea Culpa</span>
            <span class="bg-blue-100 text-blue-800 text-xs font-medium px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300">
              R 300
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
