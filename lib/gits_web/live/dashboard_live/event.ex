defmodule GitsWeb.DashboardLive.Event do
  use GitsWeb, :live_view
  require Ash.Query

  alias AshPhoenix.Form
  alias Gits.Dashboard.Account
  alias Gits.Storefront.Event
  alias Gits.Storefront.Ticket

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:slug, params["slug"])

    accounts =
      Account
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(members.user.id == ^user.id)
      |> Ash.read!()

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    event =
      Event
      |> Ash.Query.for_read(:read, %{id: params["event_id"]}, actor: user)
      |> Ash.Query.load([:tickets, :account])
      |> Ash.read_one!()

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:account_id, account.id)
      |> assign(:account_name, account.name)
      |> assign(:event_id, event.id)
      |> assign(:event, event)
      |> assign(:event_name, event.name)
      |> assign(:title, event.name)
      |> assign(:context_options, [
        %{
          to: ~p"/accounts/#{params["slug"]}/events/#{event.id}/scan",
          label: "Scan ticket",
          icon: "hero-qr-code-mini"
        },
        %{
          to: ~p"/accounts/#{params["slug"]}/events/#{event.id}/scan",
          label: "Attendees",
          icon: "hero-users-mini"
        }
      ])
      |> assign(:manage_ticket_form, nil)
      |> assign(:manage_ticket_title, nil)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_params(%{"ticket" => "new"}, _uri, socket) do
    form =
      Ticket |> Form.for_create(:create, as: "create_ticket", actor: socket.assigns.current_user)

    socket =
      socket
      |> assign(:manage_ticket_form, form)
      |> assign(:manage_ticket_title, "Create a new ticket")

    {:noreply, socket}
  end

  def handle_params(%{"ticket" => id}, _uri, socket) do
    socket =
      socket
      |> assign(:manage_ticket_title, "Edit ticket")
      |> update(:manage_ticket_form, fn _, %{event: event, current_user: user} ->
        event.tickets
        |> Enum.find(&(&1.id == id))
        |> Form.for_update(:update, as: "edit_ticket", actor: user)
      end)

    {:noreply, socket}
  end

  def handle_params(_, _uri, socket) do
    socket =
      socket
      |> assign(:manage_ticket_form, nil)
      |> assign(:manage_ticket_title, nil)

    {:noreply, socket}
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
