defmodule GitsWeb.DashboardLive.Event do
  use GitsWeb, :dashboard_live_view
  require Ash.Query

  alias AshPhoenix.Form
  alias Gits.Storefront.Event
  alias Gits.Storefront.Ticket

  defp load_defalts(socket, unsigned_params) do
    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          events:
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(id == ^unsigned_params["event_id"])
            |> Ash.Query.load([:masked_id, :tickets, :address, :payment_method_required?])
        ],
        actor: user
      )

    [event] = account.events

    socket
    |> assign(:event, event)
    |> assign(:event_name, event.name)
    |> assign(:title, event.name)
  end

  def handle_params(%{"ticket" => "new"} = unsigned_params, _uri, socket) do
    form =
      Ticket |> Form.for_create(:create, as: "create_ticket", actor: socket.assigns.current_user)

    socket
    |> assign(:manage_ticket_form, form)
    |> assign(:manage_ticket_title, "Create a new ticket")
    |> load_defalts(unsigned_params)
    |> noreply()
  end

  def handle_params(%{"ticket" => id} = unsigned_params, _uri, socket) do
    socket
    |> assign(:manage_ticket_title, "Edit ticket")
    |> update(:manage_ticket_form, fn _, %{event: event, current_user: user} ->
      event.tickets
      |> Enum.find(&(&1.id == id))
      |> Form.for_update(:update, as: "edit_ticket", actor: user)
    end)
    |> load_defalts(unsigned_params)
    |> noreply()
  end

  def handle_params(unsigned_params, _uri, socket) do
    socket
    |> assign(:manage_ticket_form, nil)
    |> assign(:manage_ticket_title, nil)
    |> load_defalts(unsigned_params)
    |> noreply()
  end

  def handle_event("publish_event", _unsigned_params, socket) do
    %{event: event, current_user: user} = socket.assigns

    socket =
      event
      |> Ash.Changeset.for_update(:publish, %{}, actor: user)
      |> Ash.update()
      |> case do
        {:ok, event} ->
          socket |> assign(:event, event)

        {:error, _} ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event("delete_ticket", %{"id" => id}, socket) do
    socket =
      socket
      |> update(:event, fn current_event, %{current_user: user} ->
        current_event.tickets
        |> Enum.find(&(&1.id == id))
        |> Ash.Changeset.for_destroy(:destroy, %{}, actor: user)
        |> Ash.destroy()
        |> case do
          :ok ->
            %Event{
              current_event
              | tickets: current_event.tickets |> Enum.filter(&(&1.id != id))
            }

          _ ->
            current_event
        end
      end)

    {:noreply, socket}
  end

  def handle_event("submit", %{"edit_ticket" => params}, socket) do
    user = socket.assigns.current_user
    event = socket.assigns.event

    socket =
      socket.assigns.manage_ticket_form
      |> Form.validate(params)
      |> Form.submit()
      |> case do
        {:ok, updated_ticket} ->
          socket
          |> assign(:event, %Event{
            event
            | tickets:
                event.tickets
                |> Enum.map(fn ticket ->
                  if(ticket.id == updated_ticket.id,
                    do: updated_ticket |> Ash.load!(:price, actor: user),
                    else: ticket
                  )
                end)
          })
          |> push_patch(
            to: ~p"/accounts/#{socket.assigns.slug}/events/#{socket.assigns.event.id}"
          )

        {:error, form} ->
          socket |> assign(:manage_ticket_form, form)
      end

    {:noreply, socket}
  end

  def handle_event("submit", %{"create_ticket" => params}, socket) do
    user = socket.assigns.current_user
    event = socket.assigns.event

    socket =
      socket.assigns.manage_ticket_form
      |> Form.validate(Map.put(params, :event, event))
      |> Form.submit()
      |> case do
        {:ok, ticket} ->
          socket
          |> assign(:event, %Event{
            event
            | tickets: event.tickets ++ [ticket |> Ash.load!(:price, actor: user)]
          })
          |> push_patch(
            to: ~p"/accounts/#{socket.assigns.slug}/events/#{socket.assigns.event.id}"
          )

        {:error, form} ->
          socket |> assign(:manage_ticket_form, form)
      end

    {:noreply, socket}
  end
end
