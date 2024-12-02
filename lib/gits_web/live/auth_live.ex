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
      <div class="mt-4 flex size-10 items-center justify-center rounded-lg bg-zinc-100 text-zinc-500">
        <.icon name="i-lucide-inbox" />
      </div>
    <% else %>
      <.form :let={f} for={@form} class="grid" phx-submit="submit" method="post">
        <h1 class="text-xl font-semibold">Welcome back</h1>
        <p class="mt-4 text-sm text-zinc-500">
          Sign in using your email address and we'll send you a magic link.
        </p>

        <.input field={f[:email]} type="email" class="mt-4" label="Email address" />

        <.button disabled={@disabled_submit?} type="submit" class="mt-6">
          <span>
            Send me a magic link
          </span>
        </.button>

        <Turnstile.widget events={[:success]} class="mt-2" appearance="interaction-only" />
      </.form>
      <div>
        <div class="flex items-center gap-2 text-sm text-zinc-400">
          <span class="h-0.5 grow border-b"></span>
          <span>or</span>
          <span class="h-0.5 grow border-b"></span>
        </div>
        <.button
          type="button"
          phx-click={JS.navigate(~p"/auth/user/google")}
          class="w-full mt-6"
          variant={:outline}
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 48 48">
            <path
              fill="#ffc107"
              d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8c-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4C12.955 4 4 12.955 4 24s8.955 20 20 20s20-8.955 20-20c0-1.341-.138-2.65-.389-3.917"
            /><path
              fill="#ff3d00"
              d="m6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4C16.318 4 9.656 8.337 6.306 14.691"
            /><path
              fill="#4caf50"
              d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238A11.9 11.9 0 0 1 24 36c-5.202 0-9.619-3.317-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44"
            /><path
              fill="#1976d2"
              d="M43.611 20.083H42V20H24v8h11.303a12.04 12.04 0 0 1-4.087 5.571l.003-.002l6.19 5.238C36.971 39.205 44 34 44 24c0-1.341-.138-2.65-.389-3.917"
            />
          </svg>
          <span>Continue with Google</span>
        </.button>
      </div>
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
