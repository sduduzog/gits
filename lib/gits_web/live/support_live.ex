defmodule GitsWeb.SupportLive do
  require Ash.Query
  require Logger
  alias Gits.Auth.User
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:options, [%{href: ~p"/portal/support/users", label: "Users"}])
    |> ok(false)
  end

  def handle_params(_unsigned_params, _uri, %{assigns: %{live_action: :users}} = socket) do
    users =
      User
      |> Ash.Query.for_read(:read, %{}, actor: socket.assigns.current_user)
      |> Ash.read!()

    socket
    |> assign(:users, users)
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket |> noreply()
  end

  def render(%{live_action: :users} = assigns) do
    ~H"""
    <div>Users</div>
    <div>
      <div :for={user <- @users}><%= user.display_name %></div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-screen-md space-y-16 p-4">
      <h1>Support</h1>
      <div class="flex flex-wrap gap-8">
        <.link :for={option <- @options} navigate={option.href} class="border p-8">
          <%= option.label %>
        </.link>
      </div>
    </div>
    """
  end
end
