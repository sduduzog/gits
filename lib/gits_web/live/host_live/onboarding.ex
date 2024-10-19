defmodule GitsWeb.HostLive.Onboarding do
  require Ash.Query
  alias Gits.Hosts.Host

  use GitsWeb, :live_view

  def render(%{live_action: :get_started} = assigns) do
    ~H"""
    <div class="w-full max-w-screen-sm">
      <h1 class="text-2xl font-semibold">Create a host account</h1>
      <p class="mt-4 text-zinc-500">
        A host account will make it easy to manage events, venues, your team and everything else to make you a successful host
      </p>
      <div>
        <label class="col-span-full grid gap-1 mt-8">
          <span class="text-sm font-medium">Host name</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>
        <div class="mt-8">
          <button class="h-9 rounded-lg px-4 py-2 text-sm font-semibold bg-zinc-950 text-zinc-50">
            Continue
          </button>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Host
    |> Ash.Query.filter(owner.id == ^socket.assigns.current_user.id)
    |> Ash.read()
    |> case do
      {:ok, [host]} ->
        socket
        |> push_navigate(to: ~p"/hosts/#{host.handle}/dashboard")
        |> ok(:host_panel)

      _ ->
        socket
        |> assign(:page_title, "Create a host account")
        |> ok(:host_panel)
    end
  end
end
