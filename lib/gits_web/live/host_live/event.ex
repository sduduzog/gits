defmodule GitsWeb.HostLive.Event do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> assign(:page_title, "The Ultimate Cheese Festival") |> ok()
  end

  defp event_body(%{tab: :overview} = assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold leading-6 text-gray-900">Orders</h1>
          <p class="mt-2 text-sm text-gray-700">
            A list of all the orders for this event including the customer name, purchase date, and amount.
          </p>
        </div>
        <div :if={false} class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
          <button
            type="button"
            class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            Add user
          </button>
        </div>
      </div>
      <div class="">
        <table class="min-w-full divide-y divide-gray-300">
          <thead>
            <tr>
              <th
                scope="col"
                class="py-3.5 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-0"
              >
                <span class="lg:inline hidden">Order #</span>
                <span class="lg:hidden">Order</span>
              </th>
              <th
                scope="col"
                class="hidden px-3 py-3.5 text-left text-sm font-semibold text-gray-900 lg:table-cell"
              >
                Purchase date
              </th>
              <th
                scope="col"
                class="hidden px-3 py-3.5 text-left text-sm font-semibold text-gray-900 sm:table-cell"
              >
                Customer
              </th>
              <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Amount
              </th>
              <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-0">
                <span class="sr-only">Edit</span>
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <tr>
              <td class="w-full max-w-0 py-4 pr-3 text-sm font-medium text-gray-900 sm:w-auto sm:max-w-none sm:pl-0">
                1
                <dl class="font-normal lg:hidden">
                  <dt class="sr-only">Purchase date</dt>
                  <dd class="mt-1 truncate text-gray-700">12 October 2024, 22:35</dd>
                  <dt class="sr-only sm:hidden">Customer</dt>
                  <dd class="mt-1 truncate text-gray-500 sm:hidden">Tom Cook</dd>
                </dl>
              </td>
              <td class="hidden px-3 py-4 text-sm text-gray-500 lg:table-cell">
                12 October 2024, 22:35
              </td>
              <td class="hidden w-2/5 px-3 py-4 text-sm text-gray-500 sm:table-cell">
                Tom Cook
              </td>
              <td class="px-3 py-4 text-sm text-gray-500 truncate">R 10 000.00</td>
              <td class="py-4 pl-3 text-right text-sm font-medium sm:pr-0">
                <button class="size-9 rounded-lg">
                  <.icon name="hero-ellipsis-vertical" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp event_body(%{tab: :attendees} = assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold leading-6 text-gray-900">Attendees</h1>
          <p class="mt-2 text-sm text-gray-700">
            A list of all the attendees who have been checked in for this event.
          </p>
        </div>
        <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
          <button class="h-9 bg-zinc-950 text-zinc-50 px-4 rounded-lg">
            <span class="text-sm font-semibold">Scan ticket</span>
          </button>
        </div>
      </div>
      <div class="">
        <table class="min-w-full divide-y divide-gray-300">
          <thead>
            <tr>
              <th
                scope="col"
                class="py-3.5 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-0"
              >
                <span class="lg:inline hidden">Order number</span>
                <span class="lg:hidden">Order</span>
              </th>
              <th
                scope="col"
                class="hidden px-3 py-3.5 text-left text-sm font-semibold text-gray-900 lg:table-cell"
              >
                Purchase date
              </th>
              <th
                scope="col"
                class="hidden px-3 py-3.5 text-left text-sm font-semibold text-gray-900 sm:table-cell"
              >
                Customer
              </th>
              <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                Amount
              </th>
              <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-0">
                <span class="sr-only">Edit</span>
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <tr>
              <td class="w-full max-w-0 py-4 pr-3 text-sm font-medium text-gray-900 sm:w-auto sm:max-w-none sm:pl-0">
                1
                <dl class="font-normal lg:hidden">
                  <dt class="sr-only">Purchase date</dt>
                  <dd class="mt-1 truncate text-gray-700">12 October 2024, 22:35</dd>
                  <dt class="sr-only sm:hidden">Customer</dt>
                  <dd class="mt-1 truncate text-gray-500 sm:hidden">Tom Cook</dd>
                </dl>
              </td>
              <td class="hidden px-3 py-4 text-sm text-gray-500 lg:table-cell">
                12 October 2024, 22:35
              </td>
              <td class="hidden w-2/5 px-3 py-4 text-sm text-gray-500 sm:table-cell">
                Tom Cook
              </td>
              <td class="px-3 py-4 text-sm text-gray-500 truncate">R 10 000.00</td>
              <td class="py-4 pl-3 text-right text-sm font-medium sm:pr-0">
                <button class="size-9 rounded-lg">
                  <.icon name="hero-ellipsis-vertical" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp event_body(%{tab: :guests} = assigns) do
    ~H"""
    <div>guests</div>
    """
  end

  def render(assigns) do
    ~H"""
    <% navigation_items = [
      %{
        label: "Overview",
        current: @live_action == :overview,
        href: ~p"/hosts/test/events/event_id/"
      },
      %{
        label: "Attendees",
        current: @live_action == :attendees,
        href: ~p"/hosts/test/events/event_id/attendees"
      },
      %{
        label: "Settings",
        current: false,
        href: ~p"/hosts/test/events/event_id/manage/summary"
      }
    ] %>

    <div class="flex p-2 lg:p-0 gap-8">
      <.link
        :for={i <- navigation_items}
        navigate={i.href}
        replace={true}
        class={[
          "text-sm text-zinc-400 rounded-lg font-medium",
          if(i.current, do: "text-zinc-950", else: "text-zinc-400")
        ]}
      >
        <%= i.label %>
      </.link>
    </div>

    <div class="py-2 grid gap-4">
      <.event_body tab={@live_action} />
    </div>
    """
  end
end
