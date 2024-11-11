defmodule GitsWeb.AuthLive do
  alias AshPhoenix.Form
  alias Gits.Accounts.User
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
    |> assign(:request_sent, nil)
    |> ok(false)
  end

  def render(assigns) do
    ~H"""
    <%= if @request_sent do %>
      <h1 class="text-xl font-semibold">Check your email!</h1>
      <p class="mt-4 text-sm text-zinc-500">
        A magic link has been sent to <%= @request_sent %>. Check your spam/junk folder, just in case.
      </p>
      <div class="mt-4 text-zinc-500 size-10 bg-zinc-100 rounded-lg flex items-center justify-center">
        <.icon name="i-lucide-inbox" />
      </div>
    <% else %>
      <.form :let={f} for={@form} class="grid" phx-submit="submit" method="post">
        <h1 class="text-xl font-semibold">Welcome back</h1>
        <p class="mt-4 text-sm text-zinc-500">
          Sign in using your email address and we'll send you a magic link.
        </p>

        <label class="mt-4 grid gap-1 text-sm">
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
          class="mt-6 rounded-lg bg-zinc-900 px-4 py-2 text-sm font-semibold text-zinc-50 disabled:opacity-70"
        >
          <span>
            Send me a magic link
          </span>
        </button>

        <Turnstile.widget events={[:success]} class="mt-8" appearance="interaction-only" />
      </.form>
    <% end %>
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
        strategy =
          AshAuthentication.Info.strategy!(User, :magic_link)

        AshAuthentication.Strategy.action(strategy, :request, unsigned_params["user"])

        socket
        |> assign(:request_sent, unsigned_params["user"]["email"])
        |> noreply()

      {:error, _} ->
        socket |> Turnstile.refresh() |> noreply()
    end
  end
end
