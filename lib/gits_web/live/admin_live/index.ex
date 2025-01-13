defmodule GitsWeb.AdminLive.Index do
  alias Gits.Support.Admin
  alias Gits.Accounts.User
  alias Gits.Storefront.Event
  alias Gits.Accounts.Host
  alias Gits.Support.Job
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    Ash.load(socket.assigns.current_user, [:admin])
    |> case do
      {:ok, %User{admin: %Admin{}} = user} ->
        socket
        |> assign(:current_user, user)
        |> ok(false)

      _ ->
        socket |> ok(:not_found)
    end
  end

  def handle_params(_, _, socket) do
    user = socket.assigns.current_user

    socket = assign(socket, :current_user, user)

    case socket.assigns.live_action do
      :jobs ->
        Ash.Query.for_read(Job, :read)
        |> Ash.Query.sort(id: :desc)
        |> Ash.read(actor: user)
        |> case do
          {:ok, jobs} ->
            socket
            |> assign(:jobs, jobs)
            |> noreply()
        end

      :hosts ->
        Ash.Query.for_read(Host, :read)
        |> Ash.Query.load([:owner, :paystack_business_name])
        |> Ash.read(actor: user)
        |> case do
          {:ok, hosts} ->
            socket
            |> assign(:hosts, hosts)
            |> noreply()
        end

      :events ->
        Ash.Query.for_read(Event, :read)
        |> Ash.Query.load([
          :published?,
          :unique_views,
          :total_orders,
          :minimum_ticket_price,
          :maximum_ticket_price
        ])
        |> Ash.read(actor: user)
        |> case do
          {:ok, events} ->
            socket
            |> assign(:events, events)
            |> noreply()
        end

      :users ->
        Ash.Query.for_read(User, :read)
        |> Ash.read(actor: user)
        |> case do
          {:ok, users} ->
            socket
            |> assign(:users, users)
            |> noreply()
        end

      _ ->
        socket |> noreply()
    end
  end

  def handle_event("retry-job", unsigned_params, socket) do
    Oban.retry_job(unsigned_params["id"] |> String.to_integer())

    user = socket.assigns.current_user

    Ash.Query.for_read(Job, :read)
    |> Ash.Query.sort(id: :desc)
    |> Ash.read(actor: user)
    |> case do
      {:ok, jobs} ->
        socket
        |> assign(:jobs, jobs)
        |> noreply()
    end
  end

  def handle_event("cancel-job", unsigned_params, socket) do
    Oban.cancel_job(unsigned_params["id"] |> String.to_integer())

    user = socket.assigns.current_user

    Ash.Query.for_read(Job, :read)
    |> Ash.Query.sort(id: :desc)
    |> Ash.read(actor: user)
    |> case do
      {:ok, jobs} ->
        socket
        |> assign(:jobs, jobs)
        |> noreply()
    end
  end
end
