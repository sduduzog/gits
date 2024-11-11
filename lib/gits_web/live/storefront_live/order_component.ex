defmodule GitsWeb.StorefrontLive.OrderComponent do
  use GitsWeb, :live_component
  require Ash.Query
  alias Gits.Storefront.Order
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
        |> assign(:form, current_form(order))
    end
    |> ok()
  end

  defp current_form(order) do
    order |> Form.for_update(:open)
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
      {:ok, order} -> socket |> assign(:order, order)
      {:error, form} -> socket |> assign(:form, form)
    end
    |> noreply()
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
        class="grid gap-8 items-start"
      >
        <div>
          <h3 class="text-lg font-semibold lg:col-span-full">Get Tickets</h3>
          <p class=" text-sm text-zinc-700">
            Please enter your email to proceed with your order.
          </p>
        </div>

        <label class="grid gap-1 grow">
          <span class="text-sm">Email address</span>
          <input type="email" name={f[:email].name} class="py-2 px-3 text-sm rounded-lg grow" />
          <span class="text-sm text-zinc-600">
            Sign in with this email to manage your tickets later.
          </span>
        </label>

        <div class="flex items-center flex-wrap justify-end gap-x-4 gap-y-2 lg:col-span-full">
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
    <div>
      <.form
        :let={f}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
        for={@form}
        class="grid gap-8 items-start"
      >
        <div>
          <h3 class="text-lg font-semibold lg:col-span-full">Get Tickets</h3>
          <p class=" text-sm text-zinc-700">
            Please enter your email to proceed with your order.
          </p>
        </div>

        <label class="grid gap-1 grow">
          <span class="text-sm">Email address</span>
          <input type="email" name={f[:email].name} class="py-2 px-3 text-sm rounded-lg grow" />
          <span class="text-sm text-zinc-600">
            Sign in with this email to manage your tickets later.
          </span>
        </label>

        <div class="flex items-center flex-wrap justify-end gap-x-4 gap-y-2 lg:col-span-full">
          <button class="rounded-lg border border-transparent bg-zinc-950 px-4 py-2 text-white">
            <span class="text-sm font-semibold">Proceed</span>
          </button>
        </div>
      </.form>
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
    <div class="grid gap-4 items-start lg:grid-cols-2 lg:gap-8">
      <h3 class="text-lg font-semibold lg:col-span-full">Tickets Summary</h3>
      <div class="flex gap-4 border rounded-xl p-2">
        <div class="size-10 bg-zinc-100 rounded-full"></div>
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
          class="text-sm flex justify-between"
        >
          <span class="text-zinc-500"><%= ticket_type %> &times; 2</span>
          <span class="font-medium">R 50.00</span>
        </div>
        <div
          :for={
            ticket_type <-
              ["Total"]
          }
          class="text-sm flex justify-between"
        >
          <span class="font-semibold"><%= ticket_type %></span>
          <span class="font-semibold">R 100.00</span>
        </div>
      </div>

      <form class="grow flex lg:hidden flex-wrap lg:col-start-2">
        <label class="grid gap-1 grow">
          <span class="text-sm">Email address</span>
          <input type="email" class="py-2 px-3 text-sm rounded-lg grow" />
        </label>
        <span></span>
      </form>

      <div class="flex items-center flex-wrap justify-end gap-x-4 gap-y-2 lg:col-span-full">
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
    <div class="grid gap-4 items-start lg:grid-cols-2 lg:gap-8">
      <h3 class="text-lg font-semibold lg:col-span-full">Nothing to see here</h3>
    </div>
    """
  end
end
