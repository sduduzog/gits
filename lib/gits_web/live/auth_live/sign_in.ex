defmodule GitsWeb.AuthLive.SignIn do
  use GitsWeb, :live_view

  alias AshPhoenix.Form
  alias Gits.Auth.User

  def mount(params, session, socket) do
    remote_ip = get_connect_info(socket, :peer_data).address

    email = session["email"]

    socket =
      socket
      |> assign(:email, email)
      |> assign(:return_to, params["return_to"])
      |> assign(:remote_ip, remote_ip)
      |> assign(:trigger_action, false)
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

  def render(assigns) do
    ~H"""
    <div class="grid w-full max-w-sm gap-2">
      <h1 class="text-xl font-medium">Sign in to <span class="font-black italic">GiTS</span></h1>
      <span class="text-sm text-zinc-500">
        Don't have an account?
        <.link class="font-medium text-zinc-700" navigate={~p"/register"}>Register here</.link>
      </span>
      <.form
        :let={f}
        for={@form}
        class="grid mt-4"
        action={~p"/auth/user/password/sign_in"}
        method="POST"
        phx-change="validate"
      >
        <input :if={@return_to} type="hidden" name={f[:return_to].name} value={@return_to} />
        <label class="grid gap-1 text-sm">
          <span>Email</span>
          <input
            type="text"
            name={f[:email].name}
            value={f[:email].value}
            class="rounded-lg px-4 py-3 text-sm"
          />
        </label>

        <label class="mt-6 grid gap-1 text-sm">
          <span>Password</span>
          <input
            type="password"
            name={f[:password].name}
            value={f[:password].value}
            class="rounded-lg px-4 py-3 text-sm"
          />
        </label>

        <Turnstile.widget theme="light" appearance="interaction-only" />

        <button class="mt-6 rounded-lg bg-zinc-900 px-4 py-3 text-sm font-medium text-zinc-50">
          Sign in
        </button>
        <div class="mt-6 flex items-center gap-4 text-zinc-500">
          <span class="grow border-t "></span>
          <span class="text-sm">Or continue with</span>
          <span class="grow border-t"></span>
        </div>
        <div class="mt-6 grid grid-cols-2 gap-6 opacity-30">
          <button
            type="button"
            disabled
            class="flex items-center justify-center gap-3 rounded-lg border px-4 py-3"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="size-5" viewBox="0 0 256 262">
              <path
                fill="#4285F4"
                d="M255.878 133.451c0-10.734-.871-18.567-2.756-26.69H130.55v48.448h71.947c-1.45 12.04-9.283 30.172-26.69 42.356l-.244 1.622l38.755 30.023l2.685.268c24.659-22.774 38.875-56.282 38.875-96.027"
              /><path
                fill="#34A853"
                d="M130.55 261.1c35.248 0 64.839-11.605 86.453-31.622l-41.196-31.913c-11.024 7.688-25.82 13.055-45.257 13.055c-34.523 0-63.824-22.773-74.269-54.25l-1.531.13l-40.298 31.187l-.527 1.465C35.393 231.798 79.49 261.1 130.55 261.1"
              /><path
                fill="#FBBC05"
                d="M56.281 156.37c-2.756-8.123-4.351-16.827-4.351-25.82c0-8.994 1.595-17.697 4.206-25.82l-.073-1.73L15.26 71.312l-1.335.635C5.077 89.644 0 109.517 0 130.55s5.077 40.905 13.925 58.602z"
              /><path
                fill="#EB4335"
                d="M130.55 50.479c24.514 0 41.05 10.589 50.479 19.438l36.844-35.974C195.245 12.91 165.798 0 130.55 0C79.49 0 35.393 29.301 13.925 71.947l42.211 32.783c10.59-31.477 39.891-54.251 74.414-54.251"
              />
            </svg>
            <span class="text-sm font-medium">Google</span>
          </button>
          <button
            class="flex items-center justify-center gap-3 rounded-lg border px-4 py-3"
            disabled
            type="button"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="size-5" viewBox="0 0 256 315">
              <path d="M213.803 167.03c.442 47.58 41.74 63.413 42.197 63.615c-.35 1.116-6.599 22.563-21.757 44.716c-13.104 19.153-26.705 38.235-48.13 38.63c-21.05.388-27.82-12.483-51.888-12.483c-24.061 0-31.582 12.088-51.51 12.871c-20.68.783-36.428-20.71-49.64-39.793c-27-39.033-47.633-110.3-19.928-158.406c13.763-23.89 38.36-39.017 65.056-39.405c20.307-.387 39.475 13.662 51.889 13.662c12.406 0 35.699-16.895 60.186-14.414c10.25.427 39.026 4.14 57.503 31.186c-1.49.923-34.335 20.044-33.978 59.822M174.24 50.199c10.98-13.29 18.369-31.79 16.353-50.199c-15.826.636-34.962 10.546-46.314 23.828c-10.173 11.763-19.082 30.589-16.678 48.633c17.64 1.365 35.66-8.964 46.64-22.262" />
            </svg>
            <span class="text-sm font-medium">Apple</span>
          </button>
        </div>
      </.form>
    </div>
    """
  end
end
