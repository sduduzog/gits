defmodule GitsWeb.DashboardLive.Team do
  use GitsWeb, :live_view

  alias Gits.Dashboard.Account
  alias Gits.Dashboard.Invite
  alias Gits.Dashboard.Member

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()
      |> Enum.map(fn item -> %{id: item.id, name: item.name} end)

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    members =
      Member
      |> Ash.Query.for_read(:read_for_dashboard, %{}, actor: user)
      |> Ash.read!()

    invites =
      Invite
      |> Ash.Query.for_read(:read_for_dashboard, %{}, actor: user)
      |> Ash.read!()

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Team")
      |> assign(:context_options, nil)
      |> assign(:action, params["action"])
      |> assign(:accounts, accounts)
      |> assign(:account_name, account.name)
      |> assign(:members, members)
      |> assign(:invites, invites)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", _unsigned_params, socket) do
    slug = socket.assigns.slug
    {:noreply, redirect(socket, to: ~p"/accounts/#{slug}/team")}
  end

  def handle_event("resend_invite", unsigned_params, socket) do
    socket.assigns.invites
    |> Enum.find(fn item ->
      item.id ==
        unsigned_params["id"]
    end)
    |> Ash.Changeset.for_update(:resend, %{}, actor: socket.assigns.current_user)
    |> Ash.update!()

    {:noreply, socket}
  end

  def handle_event("cancel_invite", unsigned_params, socket) do
    socket =
      socket
      |> update(:invites, fn current_invites, %{current_user: user} ->
        current_invites
        |> Enum.find(fn item ->
          item.id ==
            unsigned_params["id"]
        end)
        |> Ash.Changeset.for_update(:cancel, %{}, actor: user)
        |> Ash.update!()

        current_invites
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-xl font-semibold"><%= @account_name %>'s team</h1>
    <div class="space-y-2">
      <div class="grid-cols-[6fr_2fr_1fr_0.5fr] grid gap-2 pb-2 text-sm text-zinc-500 md:border-b">
        <span class="col-span-full md:col-span-1">Member</span>
        <span class="hidden md:inline-flex">Email</span>
        <span class="hidden md:inline-flex">Role</span>
      </div>
      <div class="divide-y divide-zinc-100">
        <div
          :for={member <- @members}
          class="grid-cols-[6fr_2fr_1fr_0.5fr] grid items-start gap-2 py-2 text-sm md:items-center"
        >
          <div class="col-span-3 flex flex-wrap items-center gap-2 md:col-span-1">
            <img src="/images/placeholder.png" alt="" class="size-10 rounded-full" />
            <div class="flex items-center gap-2 text-sm">
              <span class="font-medium"><%= member.user.display_name %></span>
              <span
                :if={member.user.id == @current_user.id}
                class="ring-green-600/20 inline-flex items-center rounded-full bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset"
              >
                You
              </span>
            </div>
            <span class="pl-12 text-xs text-zinc-500 md:hidden">
              <%= member.user.email %> &bull; <%= member.role |> Gits.role_to_readable_string() %>
            </span>
          </div>
          <span class="hidden md:inline-flex"><%= member.user.email %></span>
          <span class="hidden items-center justify-self-start rounded-md bg-gray-100 px-1.5 py-0.5 text-xs font-medium text-gray-600 md:inline-flex">
            <%= member.role |> Gits.role_to_readable_string() %>
          </span>
          <button class="inline-flex justify-self-end rounded-lg p-1">
            <.icon name="hero-ellipsis-vertical-mini" />
          </button>
        </div>

        <div
          :for={invite <- @invites}
          class="grid-cols-[6fr_2fr_1fr_0.5fr] grid items-start gap-2 py-2 text-sm md:items-center"
        >
          <div class="col-span-3 flex flex-wrap gap-2 md:col-span-1">
            <img src="/images/placeholder.png" alt="" class="size-10 rounded-full" />
            <div class="grid text-xs">
              <span class="font-medium"><%= invite.email %></span>
              <span class="text-zinc-500">
                Invitation pending, sent <%= invite.created_at
                |> Timex.local()
                |> Timex.format!("%e %b %Y, %R %p", :strftime) %>
              </span>
            </div>
            <span class="pl-12 text-xs text-zinc-500 md:hidden">
              <%= invite.email %> &bull; <%= invite.role |> Gits.role_to_readable_string() %>
            </span>
          </div>
          <span class="hidden md:inline-flex"><%= invite.email %></span>
          <span class="hidden items-center justify-self-start rounded-md bg-gray-100 px-1.5 py-0.5 text-xs font-medium text-gray-600 md:inline-flex">
            <%= invite.role |> Gits.role_to_readable_string() %>
          </span>

          <div
            class="relative justify-self-end"
            phx-hook="Dropdown"
            phx-click-away={
              JS.hide(
                to: "#invite-dropdown-#{invite.id}>div[data-dropdown]",
                transition:
                  {"transition ease-in duration-75", "transform opacity-100 scale-100",
                   "transform opacity-0 scale-95"}
              )
            }
            id={"invite-dropdown-#{invite.id}"}
          >
            <button
              class="inline-flex justify-self-end rounded-lg p-1"
              phx-click={
                JS.toggle(
                  to: "#invite-dropdown-#{invite.id}>div[data-dropdown]",
                  in:
                    {"transition duration-100 ease-out", "transform opacity-0 scale-95",
                     "transform opacity-100 scale-100"},
                  out:
                    {"transition ease-in duration-75", "transform opacity-100 scale-100",
                     "transform opacity-0 scale-95"}
                )
              }
              data-dropdown
            >
              <.icon name="hero-ellipsis-vertical-mini" />
            </button>
            <div
              class="absolute top-0 left-0 z-10 hidden max-w-max divide-y divide-gray-100 rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
              role="menu"
              aria-orientation="vertical"
              aria-labelledby="menu-button"
              tabindex="-1"
              data-dropdown
              phx-click={
                JS.hide(
                  to: "#invite-dropdown-#{invite.id}>div[data-dropdown]",
                  transition:
                    {"transition ease-in duration-75", "transform opacity-100 scale-100",
                     "transform opacity-0 scale-95"}
                )
              }
            >
              <div class="w-56 py-1" role="none">
                <button
                  href="#"
                  class="block w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-zinc-100 hover:text-zinc-900"
                  role="menuitem"
                  tabindex="-1"
                  id="menu-item-0"
                  phx-click={
                    JS.hide(
                      to: "#invite-dropdown-#{invite.id}>div[data-dropdown]",
                      transition:
                        {"transition ease-in duration-75", "transform opacity-100 scale-100",
                         "transform opacity-0 scale-95"}
                    )
                    |> JS.push("resend_invite")
                  }
                  phx-value-id={invite.id}
                >
                  Resend
                </button>
                <a
                  href="#"
                  class="block px-4 py-2 text-sm text-rose-600 hover:bg-rose-100 hover:text-rose-900"
                  role="menuitem"
                  tabindex="-1"
                  id="menu-item-1"
                  phx-click={
                    JS.hide(
                      to: "#invite-dropdown-#{invite.id}>div[data-dropdown]",
                      transition:
                        {"transition ease-in duration-75", "transform opacity-100 scale-100",
                         "transform opacity-0 scale-95"}
                    )
                    |> JS.push("cancel_invite")
                  }
                  phx-value-id={invite.id}
                >
                  Cancel
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
