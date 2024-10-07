defmodule GitsWeb.HostLive.Event do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> assign(:page_title, "The Ultimate Cheese Festival") |> ok()
  end

  defp event_body(%{tab: :overview} = assigns) do
    ~H"""
    <h2>Orders</h2>
    <div class="overflow-x-auto ring-1 ring-black ring-opacity-5 rounded-lg">
      <table class="min-w-full divide-y divide-gray-300">
        <thead class="bg-gray-50">
          <tr>
            <th
              scope="col"
              class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold truncate text-gray-900 sm:pl-6"
            >
              Order #
            </th>
            <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
              Created at
            </th>
            <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
              Status
            </th>
            <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
              Customer
            </th>
            <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6">
              <span class="sr-only">Options</span>
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200 bg-white">
          <tr>
            <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
              1
            </td>
            <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">45 minutes ago</td>
            <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
              <div class="rounded-md bg-green-50 px-2 inline-flex py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
                Paid
              </div>
            </td>
            <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">Tom Cook</td>
            <td class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
              <a href="#" class="text-indigo-600 hover:text-indigo-900"></a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp event_body(%{tab: :attendees} = assigns) do
    ~H"""
    <div>attendees</div>
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
        label: "Guests",
        current: @live_action == :guests,
        href: ~p"/hosts/test/events/event_id/guests"
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
