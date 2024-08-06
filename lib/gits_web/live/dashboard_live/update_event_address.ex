defmodule GitsWeb.DashboardLive.UpdateEventAddress do
  alias Gits.Admissions.Address
  alias Gits.GoogleApi.Places
  use GitsWeb, :dashboard_live_view

  alias Gits.Storefront.Event

  def handle_params(%{"place_id" => place_id} = unsigned_params, _uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          events:
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(id == ^unsigned_params["event_id"])
        ],
        actor: user
      )

    [event] = account.events

    socket =
      place_id
      |> Places.fetch_place_details()
      |> case do
        {:ok, details} -> socket |> assign(:selected, details)
      end

    socket
    |> assign(:event, event)
    |> assign(:suggestions, [])
    |> noreply()
  end

  def handle_params(unsigned_params, _uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          events:
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(id == ^unsigned_params["event_id"])
        ],
        actor: user
      )

    [event] = account.events

    socket
    |> assign(:event, event)
    |> assign(:suggestions, [])
    |> assign(:selected, nil)
    |> noreply()
  end

  def handle_event("confirm", _unsigned_params, socket) do
    %{current_user: user, event: event, selected: address, account: account} = socket.assigns

    event
    |> Ash.Changeset.for_update(:update_address, %{address: address}, actor: user)
    |> Ash.update()

    socket
    |> push_navigate(to: ~p"/accounts/#{account.id}/events/#{event.id}")
    |> noreply()
  end

  def handle_event("cancel", _unsigned_params, socket) do
    socket
    |> assign(:selected, nil)
    |> noreply()
  end

  def handle_event("search", unsigned_params, socket) do
    unsigned_params["query"]
    |> Places.search_for_suggestions()
    |> case do
      {:ok, suggestions} -> socket |> assign(:suggestions, suggestions)
      _ -> socket
    end
    |> noreply()
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-2 md:flex-row">
      <.link
        navigate={~p"/accounts/#{@slug}/events"}
        class="text-sm flex gap-2 text-zinc-400 hover:text-zinc-700"
      >
        <.icon name="hero-chevron-left-mini" />
        <span>Events</span>
      </.link>

      <.link
        navigate={~p"/accounts/#{@slug}/events/#{@event.id}"}
        class="flex gap-2 text-sm text-zinc-400 hover:text-zinc-700"
      >
        <.icon name="hero-slash-mini" />
        <span><%= @event.name %></span>
      </.link>

      <div class="flex gap-2 text-sm text-zinc-600">
        <.icon name="hero-slash-mini" />
        <span>Update address</span>
      </div>
    </div>
    <h1 class="px-4 text-xl font-semibold">Update address</h1>

    <%= if is_nil(@selected) do %>
      <.form :let={f} for={%{}} phx-change="search" class="w-full">
        <.input
          phx-debounce="300"
          field={f[:query]}
          class="w-full"
          type="search"
          autocomplete="off"
          placeholder="Search i.e. Artistry, The Bat Center..."
        />
      </.form>

      <div class=" grid gap-2">
        <button
          :for={suggestion <- @suggestions}
          phx-click={
            JS.patch(~p"/accounts/#{@slug}/events/#{@event.id}/address?place_id=#{suggestion.id}")
          }
          phx-value-id={suggestion.id}
          class="flex max-w-screen-md items-center gap-2 truncate rounded-md p-4 text-sm hover:bg-zinc-50"
        >
          <span class="shrink-0 truncate "><%= suggestion.main_text %></span>
          <span class="truncate text-zinc-600">
            <%= suggestion.secondary_text %>
          </span>
        </button>
      </div>
    <% else %>
      <div class="grid gap-8 pt-2">
        <div class="grid max-w-screen-md items-center gap-2 rounded-md border p-4 text-sm">
          <div class="flex flex-wrap items-center gap-x-2 gap-y-1">
            <span class="shrink-0"><%= @selected.display_name %></span>
            <span class="grow text-zinc-600">
              <%= @selected.short_format_address %>
            </span>
          </div>
          <div class="flex justify-between text-zinc-600">
            <%= @selected.city %> &bull; <%= @selected.province %>
          </div>
        </div>
        <div class="flex max-w-screen-md gap-4 text-sm font-medium">
          <button phx-click="cancel" class="rounded-xl bg-zinc-50 px-4 py-3">Cancel</button>
          <button
            phx-click="confirm"
            class="rounded-xl bg-zinc-900 px-4 py-3 text-white md:order-first"
          >
            Confirm address
          </button>
        </div>
      </div>
    <% end %>
    """
  end
end
