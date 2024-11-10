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
      <h1 class="font-semibold text-3xl">Check your email!</h1>
      <p class="text-zinc-500 mt-4">
        A magic link has been sent to <%= @request_sent %>. Check your spam/junk folder, just in case.
      </p>
      <.link navigate={~p"/"} class="inline-flex gap-2 font-semibold text-sm mt-4">
        Go to homepage &rarr;
      </.link>
    <% else %>
      <.form :let={f} for={@form} class="grid" phx-submit="submit" method="post">
        <h1 class="font-semibold text-3xl">Sign in</h1>
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
