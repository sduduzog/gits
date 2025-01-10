defmodule GitsWeb.HostLive.EditTicket do
  require Ash.Query
  alias Gits.Storefront.TicketType
  alias AshPhoenix.Form
  alias Gits.Storefront.Event
  use GitsWeb, :live_view

  def mount(%{"public_id" => public_id}, _session, socket) do
    Ash.Query.filter(Event, public_id == ^public_id)
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, event} ->
        assign(socket, :event, event)
        |> ok(:host_panel)
    end
  end

  def handle_params(%{"ticket_id" => ticket_id}, _uri, socket) do
    %{event: event, current_user: user} = socket.assigns

    Ash.load(event, ticket_types: Ash.Query.filter(TicketType, id == ^ticket_id))
    |> case do
      {:ok, %Event{ticket_types: [type]}} ->
        socket
        |> assign(
          :form,
          Form.for_update(event, :edit_ticket_type, forms: [auto?: true], actor: user)
          |> Form.add_form([:type], data: type, type: :update, validate?: false)
        )
        |> assign(
          :archive_ticket_form,
          Form.for_update(event, :archive_ticket_type, forms: [auto?: true], actor: user)
          |> Form.add_form([:type], data: type, type: :update, validate?: false)
        )
        |> assign(:ticket_id, type.id)
        |> noreply()
    end
  end

  def handle_params(_unsigned_params, _uri, socket) do
    %{event: event, current_user: user} = socket.assigns

    socket
    |> assign(
      :form,
      Form.for_update(event, :add_ticket_type, forms: [auto?: true], actor: user)
      |> Form.add_form([:type], validate?: false)
    )
    |> assign(:archive_ticket_form, nil)
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    assign(
      socket,
      :form,
      Form.validate(socket.assigns.form, unsigned_params["form"], errors: false)
    )
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    %{form: form, host: host} = socket.assigns

    case socket.assigns.live_action do
      :add_ticket ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, event} ->
            assign(socket, :event, event)
            |> push_navigate(
              to:
                Routes.host_edit_event_path(
                  socket,
                  :tickets,
                  host.handle,
                  event.public_id
                ),
              replace: true
            )
            |> noreply()

          {:error, form} ->
            socket
            |> assign(:form, form)
            |> noreply()
        end

      :edit_ticket ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, event} ->
            socket
            |> push_patch(
              to:
                Routes.host_edit_ticket_path(
                  socket,
                  :edit_ticket,
                  host.handle,
                  event.public_id,
                  socket.assigns.ticket_id
                ),
              replace: true
            )
            |> noreply()

          {:error, form} ->
            socket
            |> assign(:form, form)
            |> noreply()
        end
    end
  end

  def handle_event("archive_ticket", unsigned_params, socket) do
    Form.submit(socket.assigns.archive_ticket_form, params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        socket
        |> push_navigate(
          to:
            Routes.host_edit_event_path(
              socket,
              :tickets,
              socket.assigns.host.handle,
              event.public_id
            ),
          replace: true
        )
        |> noreply()
    end
  end
end
