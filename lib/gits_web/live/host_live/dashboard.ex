defmodule GitsWeb.HostLive.Dashboard do
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="flex gap-8">
      <span
        :for={i <- ["1 day", "3 days", "Week", "Month"]}
        class="text-sm text-zinc-400 first:text-zinc-950 rounded-lg first:font-medium"
      >
        <%= i %>
      </span>
    </div>
    <div class="lg:flex">
      <div class="grow grid gap-4 gap-y-10 lg:grid-cols-4">
        <div class="grid gap-1">
          <span class="text-zinc-600">Revenue</span>
          <span class="text-3xl font-medium">R 0.00</span>
        </div>

        <div class="grid gap-1">
          <span class="text-zinc-600">Unique Customers</span>
          <span class="text-3xl font-medium">0</span>
        </div>

        <div class="grid gap-1">
          <span class="text-zinc-600">Event Page Views</span>
          <span class="text-3xl font-medium">0</span>
        </div>

        <div class="grid gap-1">
          <span class="text-zinc-600">Conversion Rate</span>
          <span class="text-3xl font-medium">0%</span>
        </div>
      </div>
    </div>
    <div :if={false} class="grid items-start gap-10 lg:grid-cols-12">
      <div class="col-span-full flex flex-wrap items-end justify-between gap-4 rounded-3xl border p-4 lg:col-span-8 lg:p-8">
        <div class="flex flex-col items-start gap-4">
          <div class="bg-zinc-500/5 relative inline-flex rounded-full border border-zinc-200 p-8">
            <div class="bg-zinc-500/5 absolute bottom-0 left-28 h-10 w-40 rounded-full border border-zinc-200">
            </div>
            <svg xmlns="http://www.w3.org/2000/svg" class="size-20 text-zinc-300" viewBox="0 0 14 14">
              <g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
                <rect width="13" height="9" x=".5" y="4.24" rx=".5" /><circle
                  cx="4.25"
                  cy="7.99"
                  r="1.25"
                /><path d="m3.75 13.24l4.7-4a1.32 1.32 0 0 1 1.87.15l3.07 3.68M3.5 4.24L6.25 1.1a1 1 0 0 1 1.5 0l2.75 3.14" />
              </g>
            </svg>
          </div>

          <h1 class="text-5xl font-medium">Create your first event</h1>
          <p class="text-zinc-500 lg:max-w-96">
            Start by adding the details of your event and reach your audience in no time!
          </p>
        </div>
        <div>
          <button
            phx-click={JS.navigate(~p"/hosts/test/events/new")}
            class="inline-flex rounded-lg bg-zinc-950 px-4 py-2 text-zinc-50"
          >
            <span class="text-sm font-medium">Create event</span>
          </button>
        </div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-full lg:grid-cols-4">
        <h2 class="col-span-full text-xl font-semibold">Ticket Sales</h2>
        <div class="grid gap-2 rounded-xl border p-4">
          <h3 class="text-sm font-semibold">Generated Revenue</h3>
          <span class="text-4xl font-medium">R 0.00</span>
        </div>
        <div class="grid gap-2 rounded-xl border p-4">
          <h3 class="text-sm font-semibold">Tickets Sold</h3>
          <span class="text-4xl font-medium">0</span>
        </div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-4">
        <h2 class="col-span-full text-xl font-semibold">Upcoming Events</h2>
        <div class="grid gap-2 rounded-xl border p-4">
          <div :for={_ <- []} class="flex w-full items-center gap-2 truncate">
            <span class="shrink-0 rounded-md border-2 border-zinc-400 p-1 px-2 font-semibold uppercase">
              Sep 12
            </span>
            <h3 class="grow truncate text-sm font-semibold">
              The Ultimate Cheese Festival The Ultimate Cheese Festival
            </h3>
            <button class="flex rounded-lg p-2">
              <.icon name="hero-ellipsis-vertical-mini" />
            </button>
          </div>
        </div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-8">
        <h2 class="col-span-full text-xl font-semibold">Next Event</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-8">
        <h2 class="col-span-full text-xl font-semibold">Latest Reviews</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>

      <div :if={false} class="grid gap-4 lg:col-span-4">
        <h2 class="col-span-full text-xl font-semibold">Average Rating</h2>
        <div class="grid gap-2 rounded-xl border p-4"></div>
      </div>
    </div>
    <div class="overflow-hidden">
      <h2>Transactions</h2>
      <table class="w-full text-left">
        <thead class="sr-only">
          <tr>
            <th>Amount</th>
            <th class="hidden sm:table-cell">Client</th>
            <th>More details</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="relative py-5 pr-6">
              <div class="flex gap-x-6">
                <svg
                  class="hidden h-6 w-5 flex-none text-gray-400 sm:block"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  aria-hidden="true"
                  data-slot="icon"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm-.75-4.75a.75.75 0 0 0 1.5 0V8.66l1.95 2.1a.75.75 0 1 0 1.1-1.02l-3.25-3.5a.75.75 0 0 0-1.1 0L6.2 9.74a.75.75 0 1 0 1.1 1.02l1.95-2.1v4.59Z"
                    clip-rule="evenodd"
                  />
                </svg>
                <div class="flex-auto">
                  <div class="flex items-start gap-x-3">
                    <div class="text-sm font-medium leading-6 text-gray-900">$7,600.00 USD</div>
                    <div class="rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
                      Paid
                    </div>
                  </div>
                  <div class="mt-1 text-xs leading-5 text-gray-500">$500.00 tax</div>
                </div>
              </div>
              <div class="absolute bottom-0 right-full h-px w-screen bg-gray-100"></div>
              <div class="absolute bottom-0 left-0 h-px w-screen bg-gray-100"></div>
            </td>
            <td class="hidden py-5 pr-6 sm:table-cell">
              <div class="text-sm leading-6 text-gray-900">Reform</div>
              <div class="mt-1 text-xs leading-5 text-gray-500">Website redesign</div>
            </td>
            <td class="py-5 text-right">
              <div :if={false} class="flex justify-end">
                <a
                  href="#"
                  class="text-sm font-medium leading-6 text-indigo-600 hover:text-indigo-500"
                >
                  View<span class="hidden sm:inline"> transaction</span>
                  <span class="sr-only">
                    , invoice #00012, Reform
                  </span>
                </a>
              </div>
              <div class="mt-1 text-xs leading-5 text-gray-500">
                Invoice <span class="text-gray-900">#00012</span>
              </div>
            </td>
          </tr>
          <tr>
            <td class="relative py-5 pr-6">
              <div class="flex gap-x-6">
                <svg
                  class="hidden h-6 w-5 flex-none text-gray-400 sm:block"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  aria-hidden="true"
                  data-slot="icon"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm.75-11.25a.75.75 0 0 0-1.5 0v4.59L7.3 9.24a.75.75 0 0 0-1.1 1.02l3.25 3.5a.75.75 0 0 0 1.1 0l3.25-3.5a.75.75 0 1 0-1.1-1.02l-1.95 2.1V6.75Z"
                    clip-rule="evenodd"
                  />
                </svg>
                <div class="flex-auto">
                  <div class="flex items-start gap-x-3">
                    <div class="text-sm font-medium leading-6 text-gray-900">$10,000.00 USD</div>
                    <div class="rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10">
                      Withdraw
                    </div>
                  </div>
                </div>
              </div>
              <div class="absolute bottom-0 right-full h-px w-screen bg-gray-100"></div>
              <div class="absolute bottom-0 left-0 h-px w-screen bg-gray-100"></div>
            </td>
            <td class="hidden py-5 pr-6 sm:table-cell">
              <div class="text-sm leading-6 text-gray-900">Tom Cook</div>
              <div class="mt-1 text-xs leading-5 text-gray-500">Salary</div>
            </td>
            <td class="py-5 text-right">
              <div :if={false} class="flex justify-end">
                <a
                  href="#"
                  class="text-sm font-medium leading-6 text-indigo-600 hover:text-indigo-500"
                >
                  View<span class="hidden sm:inline"> transaction</span>
                  <span class="sr-only">
                    , invoice #00011, Tom Cook
                  </span>
                </a>
              </div>
              <div class="mt-1 text-xs leading-5 text-gray-500">
                Invoice <span class="text-gray-900">#00011</span>
              </div>
            </td>
          </tr>
          <tr>
            <td class="relative py-5 pr-6">
              <div class="flex gap-x-6">
                <svg
                  class="hidden h-6 w-5 flex-none text-gray-400 sm:block"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  aria-hidden="true"
                  data-slot="icon"
                >
                  <path
                    fill-rule="evenodd"
                    d="M15.312 11.424a5.5 5.5 0 0 1-9.201 2.466l-.312-.311h2.433a.75.75 0 0 0 0-1.5H3.989a.75.75 0 0 0-.75.75v4.242a.75.75 0 0 0 1.5 0v-2.43l.31.31a7 7 0 0 0 11.712-3.138.75.75 0 0 0-1.449-.39Zm1.23-3.723a.75.75 0 0 0 .219-.53V2.929a.75.75 0 0 0-1.5 0V5.36l-.31-.31A7 7 0 0 0 3.239 8.188a.75.75 0 1 0 1.448.389A5.5 5.5 0 0 1 13.89 6.11l.311.31h-2.432a.75.75 0 0 0 0 1.5h4.243a.75.75 0 0 0 .53-.219Z"
                    clip-rule="evenodd"
                  />
                </svg>
                <div class="flex-auto">
                  <div class="flex items-start gap-x-3">
                    <div class="text-sm font-medium leading-6 text-gray-900">$2,000.00 USD</div>
                    <div class="rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10">
                      Overdue
                    </div>
                  </div>
                  <div class="mt-1 text-xs leading-5 text-gray-500">$130.00 tax</div>
                </div>
              </div>
              <div class="absolute bottom-0 right-full h-px w-screen bg-gray-100"></div>
              <div class="absolute bottom-0 left-0 h-px w-screen bg-gray-100"></div>
            </td>
            <td class="hidden py-5 pr-6 sm:table-cell">
              <div class="text-sm leading-6 text-gray-900">Tuple</div>
              <div class="mt-1 text-xs leading-5 text-gray-500">Logo design</div>
            </td>
            <td class="py-5 text-right">
              <div :if={false} class="flex justify-end">
                <a
                  href="#"
                  class="text-sm font-medium leading-6 text-indigo-600 hover:text-indigo-500"
                >
                  View<span class="hidden sm:inline"> transaction</span>
                  <span class="sr-only">
                    , invoice #00009, Tuple
                  </span>
                </a>
              </div>
              <div class="mt-1 text-xs leading-5 text-gray-500">
                Invoice <span class="text-gray-900">#00009</span>
              </div>
            </td>
          </tr>

          <tr>
            <td class="relative py-5 pr-6">
              <div class="flex gap-x-6">
                <svg
                  class="hidden h-6 w-5 flex-none text-gray-400 sm:block"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  aria-hidden="true"
                  data-slot="icon"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm-.75-4.75a.75.75 0 0 0 1.5 0V8.66l1.95 2.1a.75.75 0 1 0 1.1-1.02l-3.25-3.5a.75.75 0 0 0-1.1 0L6.2 9.74a.75.75 0 1 0 1.1 1.02l1.95-2.1v4.59Z"
                    clip-rule="evenodd"
                  />
                </svg>
                <div class="flex-auto">
                  <div class="flex items-start gap-x-3">
                    <div class="text-sm font-medium leading-6 text-gray-900">$14,000.00 USD</div>
                    <div class="rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
                      Paid
                    </div>
                  </div>
                  <div class="mt-1 text-xs leading-5 text-gray-500">$900.00 tax</div>
                </div>
              </div>
              <div class="absolute bottom-0 right-full h-px w-screen bg-gray-100"></div>
              <div class="absolute bottom-0 left-0 h-px w-screen bg-gray-100"></div>
            </td>
            <td class="hidden py-5 pr-6 sm:table-cell">
              <div class="text-sm leading-6 text-gray-900">SavvyCal</div>
              <div class="mt-1 text-xs leading-5 text-gray-500">Website redesign</div>
            </td>
            <td class="py-5 text-right">
              <div :if={false} class="flex justify-end">
                <a
                  href="#"
                  class="text-sm font-medium leading-6 text-indigo-600 hover:text-indigo-500"
                >
                  View<span class="hidden sm:inline"> transaction</span>
                  <span class="sr-only">
                    , invoice #00010, SavvyCal
                  </span>
                </a>
              </div>
              <div class="mt-1 text-xs leading-5 text-gray-500">
                Invoice <span class="text-gray-900">#00010</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
