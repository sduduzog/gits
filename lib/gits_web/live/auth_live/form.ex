defmodule GitsWeb.AuthLive.Form do
  use GitsWeb, :live_view

  alias AshPhoenix.Form
  alias Gits.Auth.User

  def mount(_, %{"action" => "sign_in"} = session, socket) do
    remote_ip = get_connect_info(socket, :peer_data).address
    email = session["email"]

    socket =
      socket
      |> assign(:title, "Sign in to your account")
      |> assign(:email, email)
      |> assign(:remote_ip, remote_ip)
      |> assign(:trigger_action, false)
      |> assign(:action, ~p"/auth/user/password/sign_in")
      |> assign(:is_register?, false)
      |> assign(
        :form,
        Form.for_action(User, :sign_in_with_password, as: "user")
        |> case do
          form when not is_nil(email) ->
            Form.set_data(form, %{email: email})

          form ->
            form
        end
      )

    {:ok, socket, layout: {GitsWeb.Layouts, :auth}}
  end

  def mount(_, %{"action" => "register"} = session, socket) do
    remote_ip = get_connect_info(socket, :peer_data).address

    email = session["email"]

    socket =
      socket
      |> assign(:title, "Register a new account")
      |> assign(:email, email)
      |> assign(:remote_ip, remote_ip)
      |> assign(:trigger_action, false)
      |> assign(:action, ~p"/auth/user/password/register")
      |> assign(:is_register?, true)
      |> assign(
        :form,
        Form.for_create(User, :register_with_password, as: "user")
        |> case do
          form when not is_nil(email) ->
            Form.set_data(form, %{email: email})

          form ->
            form
        end
      )

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

      {:error, _error} ->
        {:noreply, socket}
    end
  end
end
