defmodule GitsWeb.DashboardLive.TicketInvites do
  alias Gits.Storefront.TicketInvite
  alias Gits.Storefront.Ticket
  use GitsWeb, :dashboard_live_view

  alias Gits.Storefront.Event

  defp prepare_assigns(socket, params) do
    socket
    |> assign(:slug, params["slug"])
    |> assign(:event_id, params["event_id"])
    |> assign(:ticket_id, params["ticket_id"])
  end

  def handle_event("invite_attendees", unsigned_params, socket) do
    %{ticket_id: ticket_id, current_user: user, events: events, event_id: event_id, slug: slug} =
      socket.assigns

    event =
      events
      |> Enum.find(fn event -> event.id == unsigned_params["id"] |> String.to_integer() end)

    attendees =
      event.attendees
      |> Ash.load!([user: :customer], actor: user)

    ticket =
      Ticket
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id == ^ticket_id)
      |> Ash.read_one!(actor: user)

    attendees
    |> Enum.each(fn attendee ->
      attendee.user.customer

      TicketInvite
      |> Ash.Changeset.for_create(:create, %{customer: attendee.user.customer, ticket: ticket})
      |> Ash.create(actor: user)
      |> IO.inspect()
    end)

    socket
    |> assign(:events, [])
    |> push_patch(to: ~p"/accounts/#{slug}/events/#{event_id}/tickets/#{ticket_id}/invites")
    |> noreply()
  end

  def handle_params(%{"from" => "events"} = unsigned_params, _uri, socket) do
    socket =
      socket
      |> prepare_assigns(unsigned_params)

    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          events:
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(attendees_count > 0)
            |> Ash.Query.load([
              :attendees,
              :attendees_count
            ])
        ],
        actor: user
      )

    socket
    |> assign(:events, account.events)
    |> noreply()
  end

  def handle_params(unsigned_params, _uri, socket) do
    socket
    |> prepare_assigns(unsigned_params)
    |> noreply()
  end

  def render(%{events: [_]} = assigns) do
    ~H"""
    <h1 class="text-xl font-semibold">Ticket Invites</h1>
    <ul role="list" class="divide-y divide-gray-100">
      <li :for={event <- @events} class="flex items-center justify-between gap-x-6 py-5">
        <div class="min-w-0">
          <div class="flex items-start gap-x-3">
            <p class="text-sm font-semibold leading-6 text-gray-900"><%= event.name %></p>
          </div>
          <div class="mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500">
            <p class="whitespace-nowrap">
              Held <%= event.local_starts_at |> Timex.from_now() %>
            </p>
            &bull;
            <p class="truncate"><%= event.attendees_count %> attendee(s)</p>
          </div>
        </div>
        <div class="flex flex-none items-center gap-x-4">
          <button
            class="rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            phx-click="invite_attendees"
            phx-value-id={event.id}
          >
            Invite
          </button>
        </div>
      </li>
    </ul>
    """
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-xl font-semibold">Ticket Invites</h1>
    <div class="grid grid-cols-3 gap-4">
      <!-- <h2 class="col-span-full mx-auto max-w-screen-md text-xl">Cheese</h2> -->
      <.link
        patch={~p"/accounts/#{@slug}/events/#{@event_id}/tickets/#{@ticket_id}/invites?from=events"}
        class="rounded-2xl border p-4 px-6"
      >
        <h3 class="font-semibold">From previous events</h3>
      </.link>
    </div>
    """
  end
end
