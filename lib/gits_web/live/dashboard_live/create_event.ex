defmodule GitsWeb.DashboardLive.CreateEvent do
  use GitsWeb, :live_view

  alias AshPhoenix.Form
  alias Gits.Dashboard.Account
  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    form = Event |> Form.for_create(:create, as: "event", actor: user)

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Settings")
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:account_name, account.name)
      |> assign(:form, form)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_event("submit", unsigned_params, socket) do
    account = socket.assigns.account
    form = socket.assigns.form |> Form.validate(unsigned_params["event"])

    socket =
      with true <- form.valid?, {:ok, event} <- Form.submit(form) do
        socket |> push_navigate(to: ~p"/accounts/#{account.id}/events/#{event.id}")
      else
        error ->
          IO.inspect(error)
          socket
      end

    socket = socket |> assign(:form, form)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.link
        navigate={~p"/accounts/#{@slug}/events"}
        class="text-sm max-w-screen-md mx-auto flex gap-2 text-zinc-600"
      >
        <.icon name="hero-chevron-left-mini" />
        <span>Events</span>
      </.link>
    </div>

    <h1 class="mx-auto max-w-screen-md text-xl font-semibold">Create a new event</h1>
    <.simple_form
      :let={f}
      for={@form}
      phx-submit="submit"
      class="flex flex-col gap-10 max-w-screen-md mx-auto w-full md:rounded-2xl bg-white"
    >
      <div class="grid grow grid-cols-2 content-start gap-4 md:gap-8">
        <.input field={f[:name]} label="Name" class="col-span-full" />
        <.input type="textarea" field={f[:description]} label="Description" class="col-span-full" />
        <.input type="datetime-local" field={f[:starts_at]} label="Starts At" />
        <.input type="datetime-local" field={f[:ends_at]} label="Ends At" />
        <.radio_group field={f[:visibility]} class="col-span-full md:col-span-2" label="Visibility">
          <:radio value={:private}>Private</:radio>
          <:radio value={:public}>Public</:radio>
        </.radio_group>
      </div>
      <div class="flex gap-8">
        <button class="min-w-20 rounded-lg bg-zinc-700 px-4 py-3 text-sm font-medium text-white">
          Save
        </button>
      </div>
    </.simple_form>
    """
  end
end
