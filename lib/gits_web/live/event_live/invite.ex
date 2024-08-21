defmodule GitsWeb.EventLive.Invite do
  require Ash.Query

  alias Gits.Storefront.TicketInvite
  use GitsWeb, :live_view

  def handle_params(unsigned_params, _uri, socket) do
    TicketInvite
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id: unsigned_params["invite_id"])
    |> Ash.Query.load(ticket: [event: :address])
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
            <.icon name="hero-calendar" class="shrink-0" />
            <div class="grid">
              <span class="font-medium"><%= @invite.ticket.event.name %></span>
              <span class="text-zinc-500">
                <%= @invite.ticket.event.local_starts_at
                |> Timex.format!("%e %B %Y", :strftime) %>
              </span>
            </div>
          </div>

          <div class="flex items-center gap-4">
            <.icon name="hero-clock" class="shrink-0" />
            <div class="grid">
              <span class="font-medium">12:00 PM </span>
              <span class="text-zinc-500">Start Time</span>
            </div>
          </div>

          <div
            :if={not is_nil(@invite.ticket.event.address)}
            class="col-span-full flex items-center gap-4"
          >
            <.icon name="hero-map-pin" class="shrink-0" />
            <div class="grid">
              <span class="font-medium"><%= @invite.ticket.event.address.display_name %></span>
              <span class="text-zinc-500">
                <%= @invite.ticket.event.address.short_format_address %>
              </span>
            </div>
          </div>
        </div>
        <div class="space-y-4 pt-8">
          <div class="flex items-center">
            <div class="grid grow p-1">
              <span class="font-medium"><%= @invite.ticket.name %></span>
              <span class="text-zinc-500">
                Value: R <%= @invite.ticket.price |> Gits.Currency.format() %>
              </span>
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
    |> Ash.Changeset.for_update(:accept, %{}, actor: user)
    |> Ash.update()
    |> IO.inspect()

    socket |> push_navigate(to: ~p"/my/tickets") |> noreply()
  end
end
