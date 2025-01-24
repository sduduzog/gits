defmodule GitsWeb.HostLive.Events.Show.Tickets do
  alias Gits.Storefront.Event
  alias Gits.Storefront.TicketType
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  # def update(assigns, socket) do
  #   socket
  #   |> assign(
  #         :form,
  #         Form.for_update(event, :edit_ticket_type, forms: [auto?: true], actor: user)
  #         |> Form.add_form([:type], data: type, type: :update, validate?: false)
  #       )
  #   |> ok()
  # end

  def update(assigns, socket) do
    Ash.load(assigns.event, [:ticket_types])
    |> case do
      {:ok, %Event{} = event} ->
        socket
        |> assign(:event, event)
        |> assign(
          :form,
          Form.for_update(event, :add_ticket_type,
            actor: assigns.current_user,
            forms: [auto?: true]
          )
          |> Form.add_form([:type], validate?: false)
        )
    end
    |> assign(:current_user, assigns.current_user)
    |> assign(:handle, assigns.handle)
    |> assign(:host_state, assigns.host_state)
    |> assign(:host_id, assigns.host_id)
    |> ok()
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

    case socket.assigns.form.action do
      :add_ticket_type ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, event} ->
            assign(socket, :event, event)
            # |> assign(
            #   :form,
            #   Form.for_update(event, :edit_ticket_type, forms: [auto?: true], actor: user)
            #   |> Form.add_form([:type], data: type, type: :update, validate?: false)
            # )
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

      :edit_ticket_type ->
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

  def handle_event("manage_ticket", unsigned_params, socket) do
    socket |> noreply()
  end
end
