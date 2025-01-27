defmodule GitsWeb.HostLive.Events do
  alias Gits.Storefront.Event
  require Ash.Query
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    case socket.assigns.current_user do
      nil ->
        socket
        |> assign(:page_title, "Unauthorized")
        |> ok(:unauthorized)

      _ ->
        socket
        |> assign(:page_title, "Events")
        |> ok(:host)
    end
  end

  def handle_params(%{"public_id" => id, "handle" => handle}, _, socket) do
    Event
    |> Ash.Query.filter(host.handle == ^handle and public_id == ^id)
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:page_title, "Events / #{event.name}")
    end
    |> noreply()
  end

  def handle_params(%{"handle" => handle}, _, socket) do
    Event
    |> Ash.Query.filter(host.handle == ^handle)
    |> Ash.Query.sort(state: :desc, starts_at: :asc)
    |> Ash.Query.load([:name])
    |> Ash.read(actor: socket.assigns.current_user)
    |> case do
      {:ok, events} ->
        socket
        |> assign(:events, events)
    end
    |> noreply()
  end

  def handle_info({:updated_event, event}, socket) do
    socket |> assign(:event, event) |> noreply()
  end
end
