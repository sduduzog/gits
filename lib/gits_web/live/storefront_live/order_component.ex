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

      {:error, _} ->
        socket |> assign(:error, :reason)
    end
    |> ok()
  end

  defp assign_current_form(socket, order) do
    case order.state do
      :anonymous ->
        socket |> assign(:form, order |> Form.for_update(:open))

      :open ->
        order = order |> Ash.load!(:ticket_types)

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

        socket
        |> assign(:ticket_types, ticket_types)
        |> assign(:form, order |> Form.for_update(:process))

      :processed ->
        order = order |> Ash.load!([:ticket_types, :tickets])

        tickets =
          Enum.map(order.ticket_types, fn type ->
            count = Enum.count(order.tickets, &(&1.ticket_type_id == type.id))
            {type.name, count}
          end)
          |> Enum.filter(fn {_, count} -> count > 0 end)

        socket
        |> assign(:tickets, tickets)
        |> assign(:reopen_order_form, order |> Form.for_update(:reopen))
        |> assign(:confirm_form, order |> Form.for_update(:confirm))

      :completed ->
        order = order |> Ash.load!([:ticket_types, :tickets])

        tickets =
          Enum.map(order.ticket_types, fn type ->
            count = Enum.count(order.tickets, &(&1.ticket_type_id == type.id))
            {type.name, count}
          end)
          |> Enum.filter(fn {_, count} -> count > 0 end)

        socket
        |> assign(:tickets, tickets)
        |> assign(:form, order |> Form.for_update(:refund))

      _ ->
        socket |> assign(:form, nil)
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
        |> assign(:order, order)
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
        |> assign(:order, order)
        |> assign_current_form(order)
    end
    |> noreply
  end

  def handle_event("reopen", unsigned_params, socket) do
    socket.assigns.order
    |> Form.for_update(:reopen)
    |> Form.submit(params: unsigned_params["reopen_order_form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign_current_form(order)

      {:error, form} ->
        socket |> assign(:reopen_order_form, form)
    end
    |> noreply
  end

  def handle_event("confirm", unsigned_params, socket) do
    socket.assigns.order
    |> Form.for_update(:confirm)
    |> Form.submit(params: unsigned_params["confirm_form"])
    |> case do
      {:ok, order} ->
        socket
        |> assign(:order, order)
        |> assign_current_form(order)

      {:error, form} ->
        socket |> assign(:confirm_form, form)
    end
    |> noreply
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

      <.form
        for={@form}
        phx-submit="submit"
        phx-target={@myself}
        class="flex flex-wrap items-center justify-end gap-x-4 gap-y-2 lg:col-span-full"
      >
        <div class="grow pl-4">
          <span class="text-sm font-medium text-zinc-800">R 60.00</span>
        </div>

        <button class="rounded-lg border border-transparent bg-zinc-950 px-4 py-2 text-white">
          <span class="text-sm font-semibold">Continue</span>
        </button>
      </.form>
    </div>
    """
  end

  def render(%{order: %{state: :processed}} = assigns) do
    ~H"""
    <div class="grid items-start gap-8">
      <div>
        <h3 class="text-lg font-semibold lg:col-span-full">Order Summary</h3>
      </div>

      <div class="grid gap-4 divide-y">
        <div class="flex items-center gap-4">
          <div class="size-10 rounded-full bg-zinc-100"></div>
          <div class="grid gap-1 text-sm font-medium">
            <span>John Doe</span>
            <span class="text-zinc-500">john.doe@bar.com</span>
          </div>
        </div>
        <div class="grid gap-4 pt-4">
          <div :for={{name, count} <- @tickets} class="flex justify-between text-sm">
            <span class="text-zinc-500"><%= name %> &times; <%= count %></span>
            <span class="font-medium">R 50.00</span>
          </div>
        </div>

        <div class="grid gap-4 pt-4">
          <div
            :for={
              ticket_type <-
                ["Total"]
            }
            class="flex justify-between"
          >
            <span class="font-semibold"><%= ticket_type %></span>
            <span class="font-semibold">R 100.00</span>
          </div>
        </div>
      </div>

      <div class="flex flex-wrap items-center justify-end gap-x-4 gap-y-2 lg:col-span-full">
        <.form for={@reopen_order_form} phx-submit="reopen" phx-target={@myself}>
          <button class="rounded-lg border border-transparent bg-zinc-50 px-4 py-2 text-zinc-950 hover:bg-zinc-200">
            <span class="text-sm font-semibold">Go back</span>
          </button>
        </.form>

        <.form for={@confirm_form} phx-submit="confirm" phx-target={@myself}>
          <button class="rounded-lg border border-transparent bg-zinc-950 px-4 py-2 text-white">
            <span class="text-sm font-semibold">Finish</span>
          </button>
        </.form>
      </div>
    </div>
    """
  end

  def render(%{error: _} = assigns) do
    ~H"""
    <div class="grid items-start gap-2">
      <h3 class="text-lg font-semibold lg:col-span-full">Oops!</h3>
      <p class="mt-1 text-sm text-gray-500">
        Lorem ipsum dolor sit amet consectetur adipisicing elit quam corrupti consectetur.
      </p>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-end">
      <div></div>
      <div class="grow max-w-lg rounded-xl bg-zinc-100 grid gap-8 p-4 lg:px-8 lg:py-10">
        <h3 class="text-lg font-semibold lg:col-span-full">Order Summary</h3>
        <dl class="text-sm/6 grid gap-6">
          <div class="grid justify-between gap-2">
            <dt class="text-gray-600 font-medium">Customer</dt>
            <dd class="flex items-center gap-4">
              <div class="size-10 rounded-full bg-zinc-300"></div>
              <div class="grid gap-1 text-sm font-medium">
                <span>John Doe</span>
                <span class="text-zinc-500">john.doe@bar.com</span>
              </div>
            </dd>
          </div>

          <div class="grid justify-between gap-2">
            <dt class="text-gray-600 font-medium">Event</dt>
            <dd class="text-gray-500">
              The Ultimate Cheese Festival the ultimate cheese festival
            </dd>
          </div>
        </dl>
      </div>
    </div>
    """
  end
end
