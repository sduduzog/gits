defmodule GitsWeb.EventLive.Invite do
  require Ash.Query

  alias Gits.Storefront.TicketInvite
  use GitsWeb, :live_view

  def handle_params(unsigned_params, _uri, socket) do
    TicketInvite
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id: unsigned_params["invite_id"])
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, nil} -> socket |> assign(:invite, nil)
      {:ok, %TicketInvite{} = invite} -> socket |> assign(:invite, invite)
      {:error, _} -> socket |> assign(:invite, nil)
    end
    |> assign(:invite_id, unsigned_params["invite_id"])
    |> noreply()
  end

  def render(%{invite: nil} = assigns) do
    ~H"""
    <div>There's issues with this invite link</div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="p-2">
      <div class="mx-auto w-full max-w-md space-y-8 divide-y rounded-xl border p-4 text-sm md:p-8">
        <div class="grid-cols-[5fr_3fr] grid gap-4 pt-4">
          <div class="flex items-center gap-4">
            <.icon name="hero-calendar" />
            <div class="grid">
              <span class="font-medium">Special event</span>
              <span class="text-zinc-500">24 August 2024</span>
            </div>
          </div>

          <div class="flex items-center gap-4">
            <.icon name="hero-clock" />
            <div class="grid">
              <span class="font-medium">12:00 PM</span>
              <span class="text-zinc-500">Start Time</span>
            </div>
          </div>

          <div class="col-span-full flex items-center gap-4">
            <.icon name="hero-map-pin" />
            <div class="grid">
              <span class="font-medium">The Grand Ballroom</span>
              <span class="text-zinc-500">123 Main St, Anytown</span>
            </div>
          </div>
        </div>
        <div class="space-y-4 pt-8">
          <div class="flex items-center">
            <div class="grid grow p-1">
              <span class="font-medium">Patron</span>
              <span class="text-zinc-500">Value: R 0.00</span>
            </div>
            <%= if is_nil(@current_user) do %>
              <.link
                class="border py-3 px-4 rounded-lg font-medium ring-zinc-500 ring-offset-2 hover:bg-zinc-50 focus:outline-none focus-visible:ring-2 active:bg-zinc-100"
                navigate={~p"/sign-in?return_to=#{~p"/ticket-invite/#{@invite_id}"}"}
              >
                Sign in to accept
              </.link>
            <% else %>
              <button
                phx-click="accept"
                class="rounded-lg border px-4 py-3 font-medium ring-zinc-500 ring-offset-2 hover:bg-zinc-50 focus:outline-none focus-visible:ring-2 active:bg-zinc-100"
              >
                Accept Ticket
              </button>
            <% end %>
          </div>
          <p class="text-zinc-500">
            This complimentary ticket is valid for one admission to the event. It cannot be combined with any other offers or discounts.
          </p>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("accept", _unsigned_params, socket) do
    %{invite: invite, current_user: user} = socket.assigns

    invite
    |> Ash.Changeset.for_update(:accept)
    |> Ash.update(actor: user)

    socket |> noreply()
  end
end
