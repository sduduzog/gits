defmodule GitsWeb.HostLive.Events.Show.Tickets do
  alias Gits.Storefront.TicketType
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  def update(assigns, socket) do
    socket
    |> assign(
      :form,
      Form.for_create(TicketType, :create, actor: assigns.current_user, forms: [auto?: true])
      |> Form.add_form([:event], type: :read, validate?: false)
    )
    |> assign(:ticket_types, assigns.ticket_types)
    |> assign(:current_user, assigns.current_user)
    |> assign(:event_id, assigns.event_id)
    |> assign(:paid_tickets_issue?, assigns.paid_tickets_issue?)
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
      |> Form.add_form([:event], type: :read, validate?: false)
    )
    |> noreply()
  end

  def handle_event("refresh_event", _, socket) do
    send(self(), {:updated_event, socket.assigns.event})
    IO.puts("update something")
    socket |> noreply()
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
