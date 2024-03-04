defmodule GitsWeb.ComponentsLive.Header do
  use GitsWeb, :live_component
  use PhoenixHTMLHelpers

  def handle_event("go_to_register", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/register")}
  end

  def render(assigns) do
    assigns =
      assigns
      |> assign(:nav_items, [
        %{label: "Home", to: ~p"/"},
        %{label: "Search", to: ~p"/search"},
        %{label: "Tickets", to: ~p"/tickets"}
      ])
      |> assign(:menu_items, [%{label: "Sign Out", to: ~p"/sign-out"}])

    ~H"""
    <nav class="bg-white border-gray-200 dark:bg-gray-900">
      <div class="max-w-screen-2xl flex flex-wrap items-center justify-between mx-auto p-4">
        <a href="/" class="flex items-center space-x-3 rtl:space-x-reverse">
          <span class="self-center font-poppins text-2xl font-black whitespace-nowrap dark:text-white">
            GiTS
          </span>
        </a>
        <div class="flex items-center md:order-2 space-x-3 md:space-x-0 rtl:space-x-reverse">
          <%= if @current_user do %>
            <button
              type="button"
              class="flex text-sm bg-gray-800 rounded-full md:me-0 focus:ring-4 focus:ring-gray-300 dark:focus:ring-gray-600"
              id="user-menu-button"
              aria-expanded="false"
              data-dropdown-toggle="user-dropdown"
              data-dropdown-placement="bottom"
            >
              <span class="sr-only">Open user menu</span>
              <img
                class="w-8 h-8 rounded-full"
                src="https://placekitten.com/100/100"
                alt="user photo"
              />
            </button>
          <% else %>
            <button
              phx-click="go_to_register"
              phx-target={@myself}
              type="button"
              class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
            >
              Sign Up
            </button>
          <% end %>
          <!-- Dropdown menu -->
          <div
            class="z-50 hidden my-4 text-base list-none bg-white divide-y divide-gray-100 rounded-lg shadow dark:bg-gray-700 dark:divide-gray-600"
            id="user-dropdown"
          >
            <div :if={@current_user} class="px-4 py-3">
              <span class="block text-sm text-gray-900 dark:text-white">
                <%= @current_user.display_name %>
              </span>
              <span class="block text-sm  text-gray-500 truncate dark:text-gray-400">
                <%= @current_user.email %>
              </span>
            </div>
            <ul class="py-2" aria-labelledby="user-menu-button">
              <li :for={item <- @menu_items}>
                <.link
                  navigate={item.to}
                  class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-gray-200 dark:hover:text-white"
                >
                  <%= item.label %>
                </.link>
              </li>
            </ul>
          </div>
          <button
            data-collapse-toggle="navbar-user"
            type="button"
            class="inline-flex items-center p-2 w-10 h-10 justify-center text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600"
            aria-controls="navbar-user"
            aria-expanded="false"
          >
            <span class="sr-only">Open main menu</span>
            <svg
              class="w-5 h-5"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 17 14"
            >
              <path
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M1 1h15M1 7h15M1 13h15"
              />
            </svg>
          </button>
        </div>
        <div
          class="items-center justify-between hidden w-full md:flex md:w-auto md:order-1"
          id="navbar-user"
        >
          <ul class="flex flex-col font-medium p-4 md:p-0 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
            <li :for={item <- @nav_items}>
              <.link
                navigate={item.to}
                class={"block py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:hover:text-blue-700 md:p-0 dark:text-white md:dark:hover:text-blue-500 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700 #{item.label == "Test" && "Foo"}"}
              >
                <%= item.label %>
              </.link>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    """
  end
end
