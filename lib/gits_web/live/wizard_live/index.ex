defmodule GitsWeb.WizardLive.Index do
  use GitsWeb, :live_view
  use Phoenix.Component

  def mount(_, _, socket) do
    socket = socket |> assign(:current_step, 2)
    {:ok, socket}
  end

  def handle_event("go_to_home", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/", replace: true)}
  end

  def handle_event(_, _, socket) do
    socket = socket |> assign(:current_step, socket.assigns.current_step + 1)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white min-h-screen">
      <div class="max-w-screen-2xl flex flex-wrap items-center justify-between mx-auto p-4 w-full">
        <a href="/" class="flex items-center space-x-3">
          <span class="self-center font-poppins text-2xl font-black whitespace-nowrap dark:text-white">
            GiTS
          </span>
        </a>
      </div>
      <.progress current_step={@current_step} />
      <div role="none" class="grow"></div>
      <div class="mx-auto max-w-screen-2xl w-full p-4 space-y-8">
        <.create_organization_step :if={@current_step == 1} />
        <.create_event_step :if={@current_step == 2} />
        <.upload_graphics_step :if={@current_step == 3} />
        <.add_tickets_step :if={@current_step == 4} />
      </div>
    </div>
    """
  end

  attr :skippable, :boolean, default: false
  attr :cancellable, :boolean, default: false

  def controls(assigns) do
    ~H"""
    <div class="flex gap-4">
      <button
        phx-click="next_step"
        type="button"
        class="text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-gray-800 dark:hover:bg-gray-700 dark:focus:ring-gray-700 dark:border-gray-700"
      >
        Next
      </button>
      <button
        :if={@skippable}
        type="button"
        class="text-gray-900 bg-white focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700"
      >
        Skip
      </button>
      <div role="none" class="grow"></div>
      <button
        :if={@cancellable}
        phx-click="go_to_home"
        type="button"
        class="text-gray-900 bg-white focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700"
      >
        Cancel
      </button>
    </div>
    """
  end

  attr :label, :string, required: true

  def heading(assigns) do
    ~H"""
    <div class="">
      <h1 class="font-bold text-3xl"><%= @label %></h1>
    </div>
    """
  end

  attr :current_step, :integer, required: true

  def progress(assigns) do
    assigns = assign(assigns, :steps, 4)

    ~H"""
    <div class="flex items-center mx-auto w-full max-w-screen-2xl p-4" aria-label="Progress">
      <p class="text-sm font-medium">Step <%= @current_step %> of <%= @steps %></p>
      <ol role="list" class="ml-8 flex items-center space-x-5">
        <li :for={step <- 1..@steps}>
          <div class={
            cond do
              @current_step == step ->
                "relative flex items-center justify-center"

              @current_step < step ->
                "block h-2.5 w-2.5 rounded-full bg-gray-200"

              @current_step > step ->
                "block h-2.5 w-2.5 rounded-full bg-zinc-600"

              true ->
                nil
            end
          }>
            <%= if @current_step == step do %>
              <span class="absolute flex h-5 w-5 p-px" aria-hidden="true">
                <span class="h-full w-full rounded-full bg-zinc-200"></span>
              </span>
              <span class="relative block h-2.5 w-2.5 rounded-full bg-zinc-600" aria-hidden="true">
              </span>
            <% end %>
            <span class="sr-only">Step <%= step %></span>
          </div>
        </li>
      </ol>
    </div>
    """
  end

  def create_organization_step(assigns) do
    ~H"""
    <.heading label="Create your organization" />
    <form class="grid gap-4">
      <div class="">
        <label
          for="default-input"
          class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Organization name
        </label>
        <input
          type="text"
          id="default-input"
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        />
      </div>
      <div class="">
        <label for="countries" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
          Organization's bank
        </label>
        <select
          id="countries"
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        >
          <option selected>Choose a bank</option>
          <option value="US">United States</option>
          <option value="CA">Canada</option>
          <option value="FR">France</option>
          <option value="DE">Germany</option>
        </select>
      </div>
      <div class="">
        <label
          for="default-input"
          class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Account number
        </label>
        <input
          type="text"
          id="default-input"
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        />
      </div>
    </form>
    <.controls />
    """
  end

  def create_event_step(assigns) do
    ~H"""
    <.heading label="Your event details" />
    <form class="grid gap-4 grid-cols-12 max-w-screen-md">
      <div class="col-span-full sm:col-span-8">
        <label
          for="default-input"
          class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Event name
        </label>
        <input
          type="text"
          id="default-input"
          value="The Ultimate Cheese Festival"
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        />
      </div>
      <divi class="col-span-full sm:col-span-11">
        <label for="message" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
          Event description
        </label>
        <textarea
          id="message"
          rows="4"
          class="block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          placeholder="Write your thoughts here..."
        ></textarea>
      </divi>

      <div class="col-span-8 sm:col-span-3">
        <label
          for="default-input"
          class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Start date
        </label>
        <input
          type="date"
          id="default-input"
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        />
      </div>
      <div class="col-span-4 sm:col-span-2">
        <label
          for="default-input"
          class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Start time
        </label>
        <input
          type="time"
          id="default-input"
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        />
      </div>
      <div class="col-span-4">
        <label
          for="default-input"
          class="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
        >
          Venue
        </label>
        <input
          type="text"
          id="default-input"
          class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        />
      </div>
      <div class="col-span-8 self-end flex items-center gap-2 pb-3">
        <.icon name="hero-map-pin-mini" class="text-gray-500" />
        <span class="grow">No address</span>
        <button class="rounded-lg">Change</button>
      </div>
    </form>

    <.controls />
    """
  end

  def upload_graphics_step(assigns) do
    ~H"""
    <div>upload graphics</div>
    """
  end

  def add_tickets_step(assigns) do
    ~H"""
    <div>add tickets</div>
    """
  end
end
