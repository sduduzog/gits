defmodule GitsWeb.DashboardLive.Attendees do
  alias Gits.Admissions.Attendee
  use GitsWeb, :dashboard_live_view

  alias Gits.Storefront.{Customer, Event, Ticket, TicketInstance}

  defp find_ticket_instance(token, event_id) do
    TicketInstance
    |> Ash.Query.for_read(:qr_code, %{token: token})
    |> Ash.Query.filter(ticket.event.id == ^event_id)
    |> Ash.Query.load([:ticket_name, :event_name, ticket_holder_id: [token: token]])
    |> Ash.read_one(not_found_error?: true)
  end

  defp find_customer(customer_id, actor) do
    Customer
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id: customer_id)
    |> Ash.Query.load(:name)
    |> Ash.read_one(not_found_error?: true, actor: actor)
  end

  defp admit_customer(customer, instance, event, actor) do
    customer =
      customer
      |> Ash.load!([:user], actor: actor)

    Attendee
    |> Ash.Changeset.for_create(:admit, %{
      user: customer.user,
      instance: instance,
      event: event
    })
    |> Ash.create(actor: actor)
    |> case do
      {:ok, _} -> :ok
      {:error, _} -> :exists
    end
  end

  def handle_params(%{"token" => token} = unsigned_params, _uri, socket) do
    socket = socket |> load_defalts(unsigned_params)
    %{event: event, current_user: user} = socket.assigns

    with {:ok, %TicketInstance{} = instance} <- find_ticket_instance(token, event.id),
         {:ok, %Customer{} = customer} <-
           find_customer(instance.ticket_holder_id, user),
         :ok <- admit_customer(customer, instance, event, user) do
      socket
      |> assign(:scan_results, :valid)
      |> assign(:ticket_name, instance.ticket_name)
      |> assign(:customer_name, customer.name)
      |> noreply()
    else
      {:error, %Ash.Error.Unknown{}} ->
        socket
        |> assign(:scan_results, :invalid_token)
        |> noreply()

      {:error, %Ash.Error.Invalid{}} ->
        socket
        |> assign(:scan_results, :invalid_ticket)
        |> noreply()

      :exists ->
        socket
        |> assign(:scan_results, :ticket_used)
        |> noreply()

      _ ->
        socket
        |> assign(:scan_results, :default)
        |> noreply()
    end
  end

  def handle_params(unsigned_params, _uri, socket) do
    socket = socket |> load_defalts(unsigned_params)
    %{event: event, current_user: user} = socket.assigns

    Attendee
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(event.id == ^event.id)
    |> Ash.Query.load([:name, :ticket_name])
    |> Ash.read(actor: user)
    |> case do
      {:ok, attendees} ->
        socket
        |> assign(:attendees, attendees)

      _ ->
        socket |> assign(:attendees, [])
    end
    |> assign(:scan_results, :default)
    |> noreply()
  end

  defp load_defalts(socket, unsigned_params) do
    %{current_user: user, account: account, slug: slug} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          events:
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(id == ^unsigned_params["event_id"])
            |> Ash.Query.load([
              :masked_id,
              :address,
              :payment_method_required?,
              tickets: Ticket |> Ash.Query.filter(test == false) |> Ash.Query.load([:total_sold])
            ])
        ],
        actor: user
      )

    [event] = account.events

    socket
    |> assign(:event, event)
    |> assign(:event_name, event.name)
    |> assign(:title, event.name)
    |> assign(:context_options, [
      %{
        label: "Scan ticket",
        to: ~p"/accounts/#{slug}/events/#{event.id}/attendees/scan",
        icon: "hero-qr-code-mini"
      },
      %{
        label: "Attendees",
        to: ~p"/accounts/#{slug}/events/#{event.id}/attendees",
        icon: "hero-users-mini"
      }
    ])
  end

  def handle_event("scanned", unsigned_params, socket) do
    %{slug: slug, event: event} = socket.assigns

    socket
    |> push_patch(
      to: ~p"/accounts/#{slug}/events/#{event.id}/attendees/scan?token=#{unsigned_params}",
      replace: true
    )
    |> noreply()
  end

  defp error_icon(assigns) do
    ~H"""
    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
      <svg
        class="h-6 w-6 text-red-600"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        aria-hidden="true"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"
        />
      </svg>
    </div>
    """
  end

  defp scan_results_text(assigns) do
    ~H"""
    <div class="mt-3 text-center sm:mt-5">
      <h1 :if={Map.has_key?(assigns, :title)} class="pb-6 text-2xl font-bold"><%= @title %></h1>
      <h3
        :if={Map.has_key?(assigns, :subtitle)}
        class="text-base font-semibold leading-6 text-gray-900"
        id="modal-title"
      >
        <%= @subtitle %>
      </h3>
      <div :if={Map.has_key?(assigns, :description)} class="mt-2">
        <p class="text-sm text-gray-500">
          <%= @description %>
        </p>
      </div>
    </div>
    """
  end

  defp scan_results_actions(assigns) do
    ~H"""
    <div class="flex w-full max-w-sm gap-4 text-sm font-medium">
      <.link
        patch={~p"/accounts/#{@slug}/events/#{@event_id}/attendees/scan"}
        replace={true}
        class="rounded-xl text-center bg-zinc-100 px-4 py-3 grow"
      >
        Go back
      </.link>
    </div>
    """
  end

  def render(%{scan_results: :invalid_token} = assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center pt-8">
      <div>
        <.error_icon />
        <.scan_results_text title="Invalid QR code" />
      </div>
      <.scan_results_actions slug={@slug} event_id={@event.id} />
    </div>
    """
  end

  def render(%{scan_results: :invalid_ticket} = assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center pt-8">
      <div>
        <.error_icon />
        <.scan_results_text title="Invalid Ticket" />
      </div>
      <.scan_results_actions slug={@slug} event_id={@event.id} />
    </div>
    """
  end

  def render(%{scan_results: :ticket_used} = assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center pt-8">
      <div>
        <.error_icon />
        <.scan_results_text title="Used Ticket" />
      </div>
      <.scan_results_actions slug={@slug} event_id={@event.id} />
    </div>
    """
  end

  def render(%{scan_results: :valid} = assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center gap-4 pt-8">
      <div>
        <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-green-100">
          <svg
            class="h-6 w-6 text-green-600"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            aria-hidden="true"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
          </svg>
        </div>
        <div class="mt-3 text-center sm:mt-5">
          <h1 class="pb-6 text-2xl font-bold">Ticket verified</h1>
          <h3 class="text-base font-semibold leading-6 text-gray-900" id="modal-title">
            <%= @ticket_name %>
          </h3>
          <div class="mt-2">
            <p class="text-sm text-gray-500">
              <%= @customer_name %>
            </p>
          </div>
        </div>
      </div>
      <div class="flex w-full max-w-sm gap-4 p-2">
        <.link
          patch={~p"/accounts/#{@slug}/events/#{@event.id}/attendees/scan"}
          replace={true}
          class="rounded-xl grow text-center hover:bg-zinc-100 bg-zinc-50 px-4 py-3 text-sm font-semibold"
        >
          Close
        </.link>
      </div>
    </div>
    """
  end

  def render(%{live_action: :scan} = assigns) do
    ~H"""
    <div
      phx-hook="QrScanner"
      data-slug={@slug}
      data-event-id={@event.id}
      id="scannner-container"
      class="fixed inset-0 z-20 h-screen w-screen bg-white"
    >
      <div id="scanner" class="absolute inset-0 z-10 flex h-full"></div>
      <div class="absolute inset-0 z-20 flex h-full w-full items-center justify-center">
        <div class="absolute inset-x-0 top-0 flex w-full items-center gap-2 bg-white p-2">
          <.link
            patch={~p"/accounts/#{@slug}/events/#{@event.id}/attendees"}
            replace={true}
            class="flex shrink-0 rounded-xl p-3 hover:bg-zinc-100"
          >
            <.icon name="hero-arrow-left-mini" />
          </.link>
          <span id="camera-label" class="grow truncate text-right text-xs text-zinc-500"></span>
          <button id="rotate-camera" class="flex shrink-0 rounded-xl p-3 hover:bg-zinc-100">
            <.icon name="hero-arrow-path-rounded-square-mini" />
          </button>
        </div>

        <div class="size-[22rem] ring-[1000px] rounded-2xl ring-white"></div>
      </div>
    </div>
    """
  end

  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1 class="text-xl font-semibold">Attendees</h1>
    <ul role="list" class="divide-y divide-gray-100">
      <li
        :for={attendee <- @attendees}
        class="flex items-center gap-4 rounded-xl p-4 hover:bg-zinc-50 lg:px-8"
      >
        <div class="size-12 overflow-hidden rounded-full">
          <img src="/images/placeholder.png" alt="" class="size-full" />
        </div>

        <div class="grid grow gap-2">
          <span class="text-sm font-semibold"><%= attendee.name %></span>
          <span class="text-xs text-zinc-500">
            Admitted <%= attendee.created_at |> Timex.from_now() %>
          </span>
        </div>
        <div class="hidden text-right lg:grid">
          <span class="text-sm"><%= attendee.ticket_name %></span>
          <span :if={false} class="text-xs text-zinc-500"><%= attendee.ticket_name %></span>
        </div>
        <div class="text-zinc-400">
          <.icon name="hero-chevron-right-mini" />
        </div>
      </li>
    </ul>
    """
  end

  def scan_results(assigns) do
    ~H"""
    scan results
    """
  end
end
