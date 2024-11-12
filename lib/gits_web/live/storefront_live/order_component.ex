defmodule GitsWeb.StorefrontLive.OrderComponent do
  use GitsWeb, :live_component
  require Ash.Query
  alias Gits.Storefront.{Order, Ticket, TicketType}
  alias AshPhoenix.Form

  def mount(socket) do
    socket
    |> ok()
  end

  def update(%{id: ""} = _assigns, socket) do
    socket |> ok()
  end

  def update(%{id: id} = _assigns, socket) do
    Order
    |> Ash.get(id)
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign_current_form(order)
    end
    |> ok()
  end

  defp assign_current_form(socket, order) do
    order = order |> Ash.load!(:ticket_types)

    case order.state do
      :anonymous ->
        socket |> assign(:form, order |> Form.for_update(:open))

      :open ->
        ticket_types =
          order.ticket_types
          |> Enum.map(fn type ->
            order =
              order |> Ash.load!(tickets: Ash.Query.filter(Ticket, ticket_type.id == ^type.id))

            {type.id, type.name, order.tickets,
             order
             |> Form.for_update(:remove_ticket,
               forms: [
                 auto?: true
               ]
             ),
             order
             |> Form.for_update(:add_ticket,
               forms: [
                 ticket: [
                   resource: Ticket,
                   create_action: :create,
                   update_action: :update,
                   forms: [
                     ticket_type: [
                       resource: TicketType,
                       data: type,
                       create_action: :create,
                       update_action: :update
                     ]
                   ]
                 ]
               ]
             )
             |> Form.add_form([:ticket], params: %{"ticket_type" => %{"id" => type.id}})}
          end)

        socket |> assign(:ticket_types, ticket_types)
    end
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(
      :form,
      socket.assigns.form
      |> Form.validate(unsigned_params["form"])
    )
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    socket.assigns.form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        order = order |> Ash.load!([:ticket_types, :tickets])

        socket
        |> assign(:order, order)
        |> assign_current_form(order)

      {:error, form} ->
        socket |> assign(:form, form)
    end
    |> noreply()
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    socket.assigns.order
    |> Form.for_update(:add_ticket)
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order |> Ash.load!([:ticket_types, :tickets]))
        |> assign_current_form(order)
    end
    |> noreply
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    socket.assigns.order
    |> Form.for_update(:remove_ticket)
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order |> Ash.load!([:ticket_types, :tickets]))
        |> assign_current_form(order)
    end
    |> noreply
  end

  def handle_event("package_tickets", _unsigned_params, socket) do
    socket |> noreply()
  end

  def render(%{order: %{state: :anonymous}} = assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
        for={@form}
        class="grid items-start gap-8"
      >
        <div>
          <h3 class="text-lg font-semibold lg:col-span-full">Get Tickets</h3>
          <p class=" text-sm text-zinc-700">
            Please enter your email to proceed with your order.
          </p>
        </div>

        <label class="grid grow gap-1">
          <span class="text-sm">Email address</span>
          <input type="email" name={f[:email].name} class="grow rounded-lg px-3 py-2 text-sm" />
          <span class="text-sm text-zinc-600">
            Sign in with this email to manage your tickets later.
          </span>
        </label>

        <div class="flex flex-wrap items-center justify-end gap-x-4 gap-y-2 lg:col-span-full">
          <button class="rounded-lg border border-transparent bg-zinc-950 px-4 py-2 text-white">
            <span class="text-sm font-semibold">Proceed</span>
          </button>
        </div>
      </.form>
    </div>
    """
  end

  def render(%{order: %{state: :open}} = assigns) do
    ~H"""
    <div class="grid items-start gap-8">
      <div>
        <h3 class="text-lg font-semibold lg:col-span-full">Get Tickets</h3>
        <p class=" text-sm text-zinc-700"></p>
      </div>

      <div class="grid gap-4 lg:grid-cols-2">
        <div
          :for={{_, name, tickets, remove_ticket_form, add_ticket_form} <- @ticket_types}
          class="grid gap-2 rounded-xl border p-4"
        >
          <div class="flex items-center justify-between gap-4 overflow-hidden">
            <span class="grow truncate text-lg font-semibold">
              <%= name %>
            </span>
            <span class="shrink-0 text-lg font-semibold">R <%= "10.00" %></span>
          </div>
          <span class="text-sm text-zinc-500">Limited early bird tickets</span>
          <div class="flex items-center justify-end gap-4">
            <div class="grow">
              <span class="text-sm font-medium text-zinc-800">R 60.00</span>
            </div>

            <.form
              :let={f}
              phx-target={@myself}
              phx-submit="remove_ticket"
              for={remove_ticket_form}
              class="group"
            >
              <.inputs_for :let={ticket_form} field={f[:ticket]}>
                <.input
                  :if={Enum.any?(tickets)}
                  type="hidden"
                  name={ticket_form[:id].name}
                  value={List.first(tickets) |> Map.get(:id)}
                />
              </.inputs_for>

              <button
                disabled={Enum.count(tickets) == 0}
                class="flex size-12 items-center justify-center gap-1 rounded-lg bg-zinc-100 text-zinc-950 hover:bg-zinc-200 disabled:bg-zinc-50 disabled:hover:bg-zinc-50 lg:size-9 lg:text-sm"
              >
                <.icon name="i-lucide-minus" class="inline-flex group-[.phx-submit-loading]:hidden" />
                <.icon
                  name="i-lucide-loader-circle"
                  class="hidden animate-spin group-[.phx-submit-loading]:inline-flex"
                />

                <span class="sr-only">
                  Remove ticket
                </span>
              </button>
            </.form>
            <span class="w-5 text-center text-base font-medium tabular-nums text-zinc-800">
              <%= Enum.count(tickets) %>
            </span>
            <.form
              :let={f}
              phx-target={@myself}
              phx-submit="add_ticket"
              for={add_ticket_form}
              class="group"
            >
              <.inputs_for :let={ticket_form} field={f[:ticket]}>
                <.inputs_for field={ticket_form[:ticket_type]}></.inputs_for>
              </.inputs_for>
              <button class="flex size-12 items-center justify-center gap-1 rounded-lg bg-zinc-100 text-zinc-950 hover:bg-zinc-200 disabled:bg-zinc-50 disabled:hover:bg-zinc-50 lg:size-9 lg:text-sm">
                <.icon name="i-lucide-plus" class="inline-flex group-[.phx-submit-loading]:hidden" />
                <.icon
                  name="i-lucide-loader-circle"
                  class="hidden animate-spin group-[.phx-submit-loading]:inline-flex"
                />
                <span class="sr-only">
                  Add ticket
                </span>
              </button>
            </.form>
          </div>
        </div>
      </div>

      <div class="flex flex-wrap items-center justify-end gap-x-4 gap-y-2 lg:col-span-full">
        <div class="grow pl-4">
          <span class="text-sm font-medium text-zinc-800">R 60.00</span>
        </div>

        <button class="rounded-lg border border-transparent bg-zinc-950 px-4 py-2 text-white">
          <span class="text-sm font-semibold">Continue</span>
        </button>
      </div>
    </div>
    """
  end

  def render(%{section: :get_tickets} = assigns) do
    ~H"""
    <div class="grid gap-4 lg:gap-8">
      <h3 class="text-lg font-semibold">Get Tickets</h3>
      <div class="grid gap-4 lg:grid-cols-2">
        <div
          :for={
            ticket_type <-
              ["Early Access", "General", "VIP", "VVIP", "Super Access", "Geez Dude"] |> Enum.take(2)
          }
          class="space-y-2 rounded-xl border p-2"
        >
          <div class="flex justify-between">
            <span class="text-sm font-semibold"><%= ticket_type %></span>
            <span class="text-sm font-medium text-zinc-500">R 10 700.00</span>
          </div>
          <div class="space-y-2 text-xs text-zinc-700">
            <p class="line-clamp-3">
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sint ipsa voluptatum esse quis odit. Eveniet eaque quos voluptates optio consectetur voluptas earum accusamus ducimus? Fugiat cum voluptatum saepe odit placeat?
            </p>
          </div>
          <div class="flex items-center justify-end gap-2">
            <button class="inline-flex size-9 items-center justify-center rounded-lg border text-sm">
              <.icon name="i-lucide-minus" class="" />
            </button>
            <span class="w-7 text-center text-xl font-medium tabular-nums">
              0
            </span>
            <button class="inline-flex size-9 items-center justify-center rounded-lg border text-sm">
              <.icon name="i-lucide-plus" class="" />
            </button>
          </div>
        </div>
      </div>
      <div class="flex items-center justify-end gap-4">
        <span class="text-sm font-medium text-zinc-500">2 tickets for R 50.00</span>
        <button class="rounded-lg bg-zinc-950 px-4 py-2 text-white" phx-click="package_tickets">
          <span class="text-sm font-semibold">Continue</span>
        </button>
      </div>
    </div>
    """
  end

  def render(%{order: %{state: :anonymous}} = assigns) do
    ~H"""
    <div class="grid items-start gap-4 lg:grid-cols-2 lg:gap-8">
      <h3 class="text-lg font-semibold lg:col-span-full">Tickets Summary</h3>
      <div class="flex gap-4 rounded-xl border p-2">
        <div class="size-10 rounded-full bg-zinc-100"></div>
        <div class="grid text-sm font-medium">
          <span>John Doe</span>
          <span class="text-zinc-500">john.doe@bar.com</span>
        </div>
      </div>
      <div class="grid gap-4">
        <div
          :for={
            ticket_type <-
              ["Early Access", "General", "VIP", "VVIP", "Super Access", "Geez Dude"] |> Enum.take(2)
          }
          class="flex justify-between text-sm"
        >
          <span class="text-zinc-500"><%= ticket_type %> &times; 2</span>
          <span class="font-medium">R 50.00</span>
        </div>
        <div
          :for={
            ticket_type <-
              ["Total"]
          }
          class="flex justify-between text-sm"
        >
          <span class="font-semibold"><%= ticket_type %></span>
          <span class="font-semibold">R 100.00</span>
        </div>
      </div>

      <form class="flex grow flex-wrap lg:col-start-2 lg:hidden">
        <label class="grid grow gap-1">
          <span class="text-sm">Email address</span>
          <input type="email" class="grow rounded-lg px-3 py-2 text-sm" />
        </label>
        <span></span>
      </form>

      <div class="flex flex-wrap items-center justify-end gap-x-4 gap-y-2 lg:col-span-full">
        <!-- <span class="text-sm font-medium text-zinc-500"></span> -->
        <button
          class="rounded-lg border border-transparent bg-zinc-950 px-4 py-2 text-white"
          phx-click="package_tickets"
        >
          <span class="text-sm font-semibold">Proceed to Payment</span>
        </button>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="grid items-start gap-4 lg:grid-cols-2 lg:gap-8">
      <h3 class="text-lg font-semibold lg:col-span-full">Nothing to see here</h3>
    </div>
    """
  end
end
