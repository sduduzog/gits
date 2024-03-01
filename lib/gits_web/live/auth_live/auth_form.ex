defmodule GitsWeb.AuthLive.AuthForm do
  use GitsWeb, :live_component
  use PhoenixHTMLHelpers

  alias AshPhoenix.Form

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(trigger_action: false)

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:errors, Form.errors(form))
      |> assign(:trigger_action, form.valid?)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul class="error-messages">
        <%= if @form.errors do %>
          <%= for {k, v} <- @errors do %>
            <li>
              <%= humanize("#{k} #{v}") %>
            </li>
          <% end %>
        <% end %>
      </ul>
      <.form
        :let={f}
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        phx-trigger-action={@trigger_action}
        phx-target={@myself}
        action={@action}
        method="POST"
      >
        <div class="mb-5">
          <%= label(f, :email, "Your email",
            class: "block mb-2 text-sm font-medium text-gray-900 dark:text-white"
          ) %>
          <%= text_input(f, :email,
            class:
              "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500",
            placeholder: "name@flowbite.com"
          ) %>
        </div>
        <div class="mb-5">
          <%= label(f, :password, "Your password",
            class: "block mb-2 text-sm font-medium text-gray-900 dark:text-white"
          ) %>
          <%= password_input(f, :password,
            class:
              "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          ) %>
        </div>
        <%= submit(@cta,
          class:
            "text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
        ) %>
      </.form>
    </div>
    """
  end
end
