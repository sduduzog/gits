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
        |> assign(:ticket_types, event.ticket_types)

        # |> assign(
        #   :form,
        #   Form.for_update(event, :add_ticket_type,
        #     actor: assigns.current_user,
        #     forms: [auto?: true]
        #   )
        #   |> Form.add_form([:type], validate?: false)
        # )
        |> assign(
          :form,
          Form.for_create(TicketType, :create, actor: assigns.current_user, forms: [auto?: true])
          |> Form.add_form([:event], type: :read, validate?: false, data: event)
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
    %{form: form} = socket.assigns

    Form.submit(form, params: unsigned_params["form"])
    |> case do
      {:ok, ticket_type} ->
        socket
        |> assign(:ticket_types, [ticket_type])
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  def handle_event("manage_ticket", %{"id" => id}, socket) do
    ticket_type = Enum.find(socket.assigns.ticket_types, &(&1.id == id))

    socket
    |> assign(
      :form,
      Form.for_update(ticket_type, :update,
        actor: socket.assigns.current_user,
        forms: [auto?: true]
      )
    )
    |> noreply()
  end
end
