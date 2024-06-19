defmodule GitsWeb.DashboardLive.CreateEvent do
  use GitsWeb, :live_view

  alias Gits.Dashboard.Account

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Settings")
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:account_name, account.name)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.link
        navigate={~p"/accounts/#{@slug}/events"}
        class="text-sm max-w-screen-lg mx-auto flex gap-2 text-zinc-600"
      >
        <.icon name="hero-chevron-left-mini" />
        <span>Events</span>
      </.link>
    </div>

    <h1 class="mx-auto max-w-screen-lg text-xl font-semibold">Create a new event</h1>
    <.simple_form
      :let={f}
      for={%{}}
      class="flex flex-col gap-10 max-w-screen-lg mx-auto w-full md:rounded-2xl bg-white"
    >
      <div class="grid grow content-start gap-4 sm:grid-cols-2 md:grid-cols-3 md:gap-8">
        <.input field={f[:name]} label="Name" class="col-span-full" />
        <.input type="textarea" field={f[:description]} label="Description" class="col-span-full" />
        <.input type="datetime-local" field={f[:starts_at]} label="Starts At" />
        <.input type="datetime-local" field={f[:ends_at]} label="Ends At" />
      </div>
      <div class="flex gap-8">
        <button class="min-w-20 rounded-lg bg-zinc-700 px-4 py-3 text-sm font-medium text-white">
          Save
        </button>
        <button class="min-w-20 rounded-lg bg-zinc-100 px-4 py-3 text-sm font-medium">
          Cancel
        </button>
      </div>
    </.simple_form>
    """
  end
end
