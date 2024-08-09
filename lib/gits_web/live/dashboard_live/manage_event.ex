defmodule GitsWeb.DashboardLive.ManageEvent do
  use GitsWeb, :dashboard_live_view
  require Ash.Query

  alias AshPhoenix.Form
  alias Gits.Storefront.Event

  def handle_params(%{"event_id" => id}, _uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          events:
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(id == ^id)
            |> Ash.Query.load([:masked_id, :tickets, :address])
        ],
        actor: user
      )

    [event] = account.events

    form =
      event
      |> Form.for_update(:update, as: "edit_event", actor: user)

    
    socket
    |> assign(:form, form)
    |> assign(:event, event)
    |> assign(:title, "Edit event")
    |> assign(:back_link, ~p"/accounts/#{socket.assigns.slug}/events/#{event.id}")
    |> noreply()
  end

  def handle_params(_, _, socket) do
    user = socket.assigns.current_user
    form = Event |> Form.for_create(:create, as: "create_event", actor: user)

    socket
    |> assign(:form, form)
    |> assign(:event, nil)
    |> assign(:title, "Create a new event")
    |> assign(:back_link, ~p"/accounts/#{socket.assigns.slug}/events")
    |> noreply()
  end

  def handle_event("submit", %{"edit_event" => params}, socket) do
    account = socket.assigns.account

    form =
      socket.assigns.form
      |> Form.validate(params)

    with true <- form.valid?, {:ok, event} <- Form.submit(form) do
      socket |> push_navigate(to: ~p"/accounts/#{account.id}/events/#{event.id}")
    else
      {:error, %AshPhoenix.Form{} = form} ->
        socket |> assign(:form, form)

      _ ->
        socket
    end
    |> assign(:form, form)
    |> noreply()
  end

  def handle_event("submit", %{"create_event" => params}, socket) do
    account = socket.assigns.account

    form =
      socket.assigns.form |> Form.validate(Map.put(params, :account, account))

    with true <- form.valid?, {:ok, event} <- Form.submit(form) do
      socket |> push_navigate(to: ~p"/accounts/#{account.id}/events/#{event.id}/address")
    else
      {:error, %AshPhoenix.Form{} = form} ->
        socket |> assign(:form, form)

      _ ->
        socket
    end
    |> assign(:form, form)
    |> noreply()
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto flex max-w-screen-md flex-col items-start gap-2 md:flex-row">
      <.link
        navigate={~p"/accounts/#{@slug}/events"}
        class="text-sm flex gap-2 text-zinc-400 hover:text-zinc-700"
      >
        <.icon name="hero-chevron-left-mini" />
        <span>Events</span>
      </.link>

      <%= if is_nil(@event) do %>
        <div class="flex gap-2 text-sm text-zinc-600">
          <.icon name="hero-slash-mini" />
          <span>Create a new event</span>
        </div>
      <% else %>
        <.link
          navigate={~p"/accounts/#{@slug}/events/#{@event.id}"}
          class="flex gap-2 text-sm text-zinc-400 hover:text-zinc-700"
        >
          <.icon name="hero-slash-mini" />
          <span><%= @event.name %></span>
        </.link>

        <div class="flex gap-2 text-sm text-zinc-600">
          <.icon name="hero-slash-mini" />
          <span>Edit event</span>
        </div>
      <% end %>
    </div>

    <h1 class="mx-auto max-w-screen-md text-xl font-semibold"><%= @title %></h1>
    <.simple_form
      :let={f}
      for={@form}
      phx-submit="submit"
      class="flex flex-col gap-10 max-w-screen-md mx-auto w-full md:rounded-2xl bg-white"
    >
      <div class="grid grow grid-cols-2 content-start gap-4 md:gap-8">
        <.input field={f[:name]} label="Name" class="col-span-full" />
        <.input type="textarea" field={f[:description]} label="Description" class="col-span-full" />
        <.input type="datetime-local" field={f[:local_starts_at]} label="Starts At" />
        <.input type="datetime-local" field={f[:local_ends_at]} label="Ends At" />
        <.radio_group field={f[:visibility]} class="col-span-full md:col-span-2" label="Visibility">
          <:radio value={:private}>Private</:radio>
          <:radio value={:protected}>Protected</:radio>
          <:radio value={:public}>Public</:radio>
        </.radio_group>
        <.radio_group
          field={f[:payment_method]}
          class="col-span-full md:col-span-2"
          label="Payment method"
        >
          <:radio value={:none} checked>None</:radio>
          <:radio :if={@account.paystack_ready} value={:paystack}>Paystack</:radio>
          <:radio :if={@account.payfast_ready} value={:payfast}>Payfast</:radio>
        </.radio_group>
      </div>
      <div class="flex gap-8">
        <button
          :if={@current_user.confirmed_at}
          class="min-w-20 rounded-lg bg-zinc-700 px-4 py-3 text-sm font-medium text-white"
        >
          Save
        </button>
      </div>
    </.simple_form>
    """
  end
end
