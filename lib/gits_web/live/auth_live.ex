defmodule GitsWeb.AuthLive do
  alias AshPhoenix.Form
  alias Gits.Auth.User
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    remote_ip =
      socket
      |> get_connect_info(:peer_data)
      |> Map.get(:address)

    socket
    |> assign(:remote_ip, remote_ip)
    |> assign(
      :form,
      Form.for_action(User, :request_magic_link, as: "user")
    )
    |> assign(:disabled_submit?, true)
    |> assign(:trigger_submit?, false)
    |> ok(false)
  end

  def render(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@form}
      class="grid"
      action={~p"/request-magic-link"}
      phx-submit="submit"
      phx-trigger-action={@trigger_submit?}
      method="post"
    >
      <h1 class="font-semibold text-5xl">Sign in</h1>
      <p class="text-zinc-500 mt-4">Enter your email address to receive a magic link</p>
      <label class="grid gap-1 mt-8 text-sm">
        <span>Email</span>
        <input
          type="text"
          name={f[:email].name}
          value={f[:email].value}
          class="rounded-lg px-3 py-2 text-sm"
        />
      </label>
      <button
        disabled={@disabled_submit?}
        type="submit"
        class="mt-6 rounded-lg bg-zinc-900 disabled:opacity-70 px-4 py-2 text-sm font-semibold text-zinc-50"
      >
        <span>
          Send me a magic link
        </span>
      </button>

      <Turnstile.widget events={[:success]} class="mt-8" />
    </.form>
    """
  end

  def handle_event("turnstile:success", _unsigned_params, socket) do
    socket
    |> assign(:disabled_submit?, false)
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    case Turnstile.verify(unsigned_params) do
      {:ok, _} ->
        socket
        |> assign(:trigger_submit?, true)
        |> noreply()

      {:error, _} ->
        socket |> Turnstile.refresh() |> noreply()
    end
  end
end
