defmodule GitsWeb.StorefrontLive.EventListing do
  require Ash.Query
  alias Gits.Storefront.Interaction
  alias Gits.Accounts.User
  alias Gits.Storefront.{Event}
  alias AshPhoenix.Form
  use GitsWeb, :live_view

  def mount(params, session, socket) do
    remote_ip = get_connect_info(socket, :peer_data).address

    Ash.Query.filter(Event, public_id == ^params["public_id"])
    |> Ash.Query.load([
      :host,
      :venue,
      :has_tickets?,
      :minimum_ticket_price,
      :ticket_prices_vary?,
      poster: [:url]
    ])
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, %Event{} = event} ->
        if connected?(socket) do
          Ash.Changeset.for_create(Interaction, :create, %{
            type: :view,
            viewer_id: session["viewer_id"],
            event: event,
            user: socket.assigns.current_user
          })
          |> Ash.create(actor: socket.assigns.current_user)
        end

        socket
        |> assign(:verified?, not is_nil(socket.assigns.current_user))
        |> assign(:viewer_id, session["viewer_id"])
        |> assign(:remote_ip, remote_ip)
        |> assign(:event, event)
        |> assign(:page_title, event.name)
        |> SEO.assign(event)
        |> ok()

      _ ->
        socket
        |> assign(:page_title, "Not found")
        |> assign(:event, nil)
        |> ok(:not_found)
    end
  end

  def handle_params(_unsigned_params, _uri, socket) do
    case socket.assigns.event do
      %Event{} = event ->
        socket
        |> assign(
          :form,
          event
          |> Form.for_update(:create_order,
            forms: [auto?: true],
            actor: socket.assigns.current_user
          )
          |> Form.add_form([:order])
        )
        |> noreply()

      _ ->
        noreply(socket)
    end
  end

  def handle_event("turnstile:success", _, socket) do
    socket
    |> assign(:verified?, true)
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    with :ok <-
           verify_turnstile(
             unsigned_params,
             socket.assigns.remote_ip,
             socket.assigns.current_user
           ),
         {:ok, order_id} <-
           create_order(socket.assigns.form, unsigned_params["form"], socket.assigns.event) do
      socket
      |> push_navigate(
        to:
          Routes.storefront_event_order_path(
            socket,
            :index,
            socket.assigns.event.public_id,
            order_id
          )
      )
      |> noreply()
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

  defp verify_turnstile(params, remote_ip, nil) do
    case Gits.Turnstile.verify(params, remote_ip) do
      {:ok, _} ->
        :ok

      {:error, _} ->
        :error
    end
  end

  defp verify_turnstile(_, _, %User{}), do: :ok

  defp create_order(form, params, event) do
    form
    |> Form.submit(params: Map.put(params, :event, event))
    |> case do
      {:ok, %{orders: [order]}} ->
        {:ok, order.id}
    end
  end
end
