defmodule GitsWeb.AuthLive.PasswordReset do
  use GitsWeb, :live_view
  use PhoenixHTMLHelpers

  alias Gits.Accounts
  alias Gits.Accounts.User
  alias AshPhoenix.Form

  def mount(%{"token" => token}, _, socket) do
    remote_ip = get_connect_info(socket, :peer_data).address

    socket =
      socket
      |> assign(:trigger_action, false)
      |> assign(:remote_ip, remote_ip)
      |> assign(:token, token)
      |> assign(:action, ~p"/auth/user/password/reset")
      |> assign(
        :form,
        Form.for_action(User, :password_reset_with_password, api: Accounts, as: "user")
      )
      |> IO.inspect()

    {:ok, socket, layout: {GitsWeb.Layouts, :auth}}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params, errors: false)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"user" => params} = values, socket) do
    form = socket.assigns.form |> Form.validate(params)

    case Turnstile.verify(values, socket.assigns.remote_ip) do
      {:ok, _} ->
        socket =
          socket
          |> assign(:form, form)
          |> assign(:errors, Form.errors(form))
          |> assign(:trigger_action, form.valid?)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
