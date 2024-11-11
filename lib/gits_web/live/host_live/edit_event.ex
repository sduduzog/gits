defmodule GitsWeb.HostLive.EditEvent do
  alias Gits.Storefront.Event
  alias Gits.Storefront.TicketType
  alias Gits.Storefront.{Event, TicketType}
  alias AshPhoenix.Form
  require Ash.Query
  use GitsWeb, :live_view

  embed_templates "edit_event_templates/*"

  def mount(_params, _session, socket) do
    socket
    |> ok(:host_panel)
  end

  def handle_params(%{"public_id" => public_id} = unsigned_params, _uri, socket) do
    Event
    |> Ash.Query.filter(public_id == ^public_id)
    |> Ash.Query.load([:name, :ticket_types])
    |> Ash.read_one()
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:form, current_form(socket.assigns.live_action, event))
        |> show_create_ticket_modal(unsigned_params, event)
        |> show_edit_ticket_modal(unsigned_params, event)
        |> show_archive_ticket_modal(unsigned_params, event)
    end
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket
    |> assign(:form, current_form(socket.assigns.live_action))
    |> noreply()
  end

  def handle_event("close", _unsigned_params, socket) do
    case socket.assigns do
      %{event: event, host: host} ->
        socket
        |> push_navigate(
          to: Routes.host_view_event_path(socket, :overview, host.handle, event.public_id)
        )

      %{host: host} ->
        socket
        |> push_navigate(to: Routes.host_list_events_path(socket, :drafts, host.handle))
    end
    |> noreply()
  end

  def handle_event("previous", %{"from" => from}, socket) do
    %{host: host, event: event} = socket.assigns

    action =
      case from do
        "tickets" ->
          :details
      end

    socket
    |> push_patch(to: Routes.host_edit_event_path(socket, action, host.handle, event.public_id))
    |> noreply()
  end

  def handle_event("next", %{"from" => from}, socket) do
    %{host: host, event: event} = socket.assigns

    action =
      case from do
        "details" ->
          :tickets
      end

    socket
    |> push_patch(to: Routes.host_edit_event_path(socket, action, host.handle, event.public_id))
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(
      :form,
      socket.assigns.form
      |> case do
        %{type: :update} = form ->
          form |> Form.validate(unsigned_params["form"])

        %{type: :create} = form ->
          form
          |> Form.validate(Map.put(unsigned_params["form"], :host, socket.assigns.host))
      end
    )
    |> noreply()
  end

  def handle_event("details", unsigned_params, socket) do
    socket.assigns.form
    |> case do
      %{type: :update} = form ->
        {:update, form |> Form.submit(params: unsigned_params["form"])}

      %{type: :create} = form ->
        {:create,
         form
         |> Form.submit(params: Map.put(unsigned_params["form"], :host, socket.assigns.host))}
    end
    |> case do
      {:create, {:ok, event}} ->
        socket
        |> put_flash(:info, "An event was created created successfully")
        |> push_patch(
          to:
            Routes.host_edit_event_path(
              socket,
              :details,
              socket.assigns.host.handle,
              event.public_id
            )
        )

      {:update, {:ok, event}} ->
        socket |> assign(:event, event)

      {_, {:error, form}} ->
        socket |> assign(:form, form)
    end
    |> noreply()
  end

  def handle_event("tickets", unsigned_params, socket) do
    socket.assigns.form
    |> Form.validate(unsigned_params["form"])
    |> Form.submit()

    socket |> noreply()
  end

  defp current_form(:details) do
    Event
    |> Form.for_create(:create)
  end

  defp current_form(:details, event) do
    event
    |> Form.for_update(:details, forms: [auto?: true])
  end

  defp current_form(:tickets, event) do
    event
    |> Form.for_update(:update, forms: [auto?: true])
  end

  defp current_form(_, _) do
    nil
  end

  defp show_create_ticket_modal(socket, %{"modal" => "ticket", "create" => ""}, event) do
    socket
    |> assign(
      :form,
      event
      |> Form.for_update(:add_ticket_type, forms: [auto?: true])
      |> Form.add_form([:type])
    )
    |> assign(:show_create_ticket_modal, true)
  end

  defp show_create_ticket_modal(socket, _, _) do
    socket
    |> assign(:show_create_ticket_modal, false)
  end

  defp show_edit_ticket_modal(socket, %{"modal" => "ticket", "edit" => ticket_id}, event) do
    event
    |> Ash.load(ticket_types: [TicketType |> Ash.Query.filter(id == ^ticket_id)])
    |> case do
      {:ok, event} ->
        socket
        |> assign(
          :form,
          event
          |> Form.for_update(:edit_ticket_type, forms: [auto?: true])
        )
        |> assign(:show_edit_ticket_modal, true)
    end
  end

  defp show_edit_ticket_modal(socket, _, _) do
    socket
    |> assign(:show_edit_ticket_modal, false)
  end

  defp show_archive_ticket_modal(socket, %{"modal" => "ticket", "archive" => ticket_id}, event) do
    event
    |> Ash.load(ticket_types: [TicketType |> Ash.Query.filter(id == ^ticket_id)])
    |> case do
      {:ok, event} ->
        socket
        |> assign(
          :form,
          event
          |> Form.for_update(:archive_ticket_type, forms: [auto?: true])
        )
        |> assign(:show_archive_ticket_modal, true)
    end
  end

  defp show_archive_ticket_modal(socket, _, _) do
    socket
    |> assign(:show_archive_ticket_modal, false)
  end
end
