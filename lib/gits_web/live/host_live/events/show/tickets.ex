defmodule GitsWeb.HostLive.Events.Show.Tickets do
  alias Gits.Storefront.Event
  alias Gits.Storefront.TicketType
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  def update(assigns, socket) do
    Ash.load(assigns.event, :ticket_types)
    |> case do
      {:ok, %Event{} = event} ->
        socket
        |> assign(:event, event)
        |> assign(:ticket_types, event.ticket_types)
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
      Form.validate(socket.assigns.form, unsigned_params["form"],
        target: unsigned_params["_target"],
        errors: false
      )
    )
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    %{form: form} = socket.assigns

    case form.action do
      :create ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, ticket_type} ->
            socket
            |> assign(:ticket_types, socket.assigns.ticket_types ++ [ticket_type])
            |> assign_update_form(ticket_type.id)
            |> noreply()

          {:error, form} ->
            socket
            |> assign(:form, form)
            |> noreply()
        end

      :update ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, ticket_type} ->
            socket
            |> assign(
              :ticket_types,
              Enum.map(
                socket.assigns.ticket_types,
                &if(&1.id == ticket_type.id, do: ticket_type, else: &1)
              )
            )
            |> assign_update_form(ticket_type.id)
            |> noreply()

          {:error, form} ->
            socket
            |> assign(:form, form)
            |> noreply()
        end
    end
  end

  def handle_event("delete_ticket", %{"id" => id}, socket) do
    Enum.find(socket.assigns.ticket_types, &(&1.id == id))
    |> Ash.Changeset.for_destroy(:destroy)
    |> Ash.destroy(actor: socket.assigns.current_user)
    |> case do
      :ok ->
        socket
        |> assign(
          :ticket_types,
          Enum.flat_map(
            socket.assigns.ticket_types,
            &if(&1.id == id, do: [], else: [&1])
          )
        )
    end
    |> noreply()
  end

  def handle_event("sort_ticket", unsigned_params, socket) do
    displaced =
      Enum.at(socket.assigns.ticket_types, unsigned_params["new_index"])

    Ash.Changeset.for_update(socket.assigns.event, :sort_ticket_types, %{
      ticket_types: [
        %{id: unsigned_params["id"], index: unsigned_params["new_index"]},
        %{id: displaced.id, index: unsigned_params["old_index"]}
      ]
    })
    |> Ash.update(
      actor: socket.assigns.current_user,
      load: [:ticket_types]
    )
    |> case do
      {:ok, event} ->
        socket
        |> assign(:ticket_types, event.ticket_types)
        |> noreply()
    end
  end

  def handle_event("manage_ticket", %{"id" => id}, socket) do
    assign_update_form(socket, id)
    |> noreply()
  end

  def handle_event("manage_ticket", _, socket) do
    socket
    |> assign(
      :form,
      Form.for_create(TicketType, :create,
        actor: socket.assigns.current_user,
        forms: [auto?: true]
      )
      |> Form.add_form([:event], type: :read, validate?: false, data: socket.assigns.event)
    )
    |> noreply()
  end

  defp assign_update_form(socket, id) do
    ticket_type = Enum.find(socket.assigns.ticket_types, &(&1.id == id))

    socket
    |> assign(
      :form,
      Form.for_update(ticket_type, :update, actor: socket.assigns.current_user)
    )
  end
end
