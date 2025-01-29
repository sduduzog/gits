defmodule GitsWeb.HostLive.Events do
  alias Gits.Storefront.TicketType
  alias AshPhoenix.Form
  alias Gits.Accounts.Host
  alias Gits.Storefront.Event
  require Ash.Query
  use GitsWeb, :live_view
  import GitsWeb.HostComponents

  embed_templates "events/layout*"
  embed_templates "events_templates/*"
  embed_templates "events/show_event*"

  def mount(%{"public_id" => public_id, "handle" => handle}, _session, socket) do
    Ash.Query.filter(Host, handle == ^handle)
    |> Ash.Query.load([
      :payment_method_ready?,
      events:
        Ash.Query.filter(Event, public_id == ^public_id)
        |> Ash.Query.load([
          :start_date_invalid?,
          :end_date_invalid?,
          :poster_invalid?,
          :venue_invalid?,
          :has_paid_tickets?,
          :total_ticket_types,
          :ticket_types
        ])
    ])
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, %Host{events: [event]} = host} ->
        socket
        |> assign(:handle, host.handle)
        |> assign(:host_name, host.name)
        |> assign(:payment_method_ready?, host.payment_method_ready?)
        |> assign(:event, event)
        |> assign(:start_date_invalid?, event.start_date_invalid?)
        |> assign(:end_date_invalid?, event.end_date_invalid?)
        |> assign(:poster_invalid?, event.poster_invalid?)
        |> assign(:venue_invalid?, event.venue_invalid?)
        |> assign(
          :issues_count,
          [
            event.start_date_invalid?,
            event.end_date_invalid?,
            event.poster_invalid?,
            event.venue_invalid?
          ]
          |> Enum.filter(& &1)
          |> Enum.count()
        )
        |> assign(:ticket_types, event.ticket_types)
        |> assign(
          :tickets_form,
          Form.for_create(TicketType, :create,
            actor: socket.assigns.current_user,
            forms: [auto?: true]
          )
          |> Form.add_form([:event], type: :read, validate?: false, data: event)
        )
        |> assign(:host, host)
        |> assign(:page_title, "Events / #{event.name}")
        |> ok(:host)
    end
  end

  def mount(%{"handle" => handle}, _session, socket) do
    Ash.Query.filter(Host, handle == ^handle)
    |> Ash.Query.load(
      events:
        Ash.Query.sort(Event, state: :desc, starts_at: :asc)
        |> Ash.Query.load([:name])
    )
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, %Host{events: events}} ->
        socket
        |> assign(:events, events)
        |> ok(:host)
    end
  end

  def handle_params(_, _, socket) do
    socket |> noreply()
  end

  def handle_event("validate_tickets_form", unsigned_params, socket) do
    assign(
      socket,
      :tickets_form,
      Form.validate(socket.assigns.tickets_form, unsigned_params["form"],
        target: unsigned_params["_target"],
        errors: false
      )
    )
    |> noreply()
  end

  def handle_event("submit_tickets_form", unsigned_params, socket) do
    %{tickets_form: form} = socket.assigns

    case form.action do
      :create ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, ticket_type} ->
            socket
            |> assign(:ticket_types, socket.assigns.ticket_types ++ [ticket_type])
            |> assign_update_ticket_form(ticket_type.id)
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
            |> assign_update_ticket_form(ticket_type.id)
            |> noreply()

          {:error, form} ->
            socket
            |> assign(:form, form)
            |> noreply()
        end
    end
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
    assign_update_ticket_form(socket, id)
    |> noreply()
  end

  def handle_event("manage_ticket", _, socket) do
    socket
    |> assign(
      :tickets_form,
      Form.for_create(TicketType, :create,
        actor: socket.assigns.current_user,
        forms: [auto?: true]
      )
      |> Form.add_form([:event], type: :read, validate?: false, data: socket.assigns.event)
    )
    |> noreply()
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

  def handle_info({:updated_event, event}, socket) do
    socket |> put_flash(:info, "Event updated") |> assign(:event, event) |> noreply()
  end

  defp assign_update_ticket_form(socket, id) do
    ticket_type = Enum.find(socket.assigns.ticket_types, &(&1.id == id))

    socket
    |> assign(
      :tickets_form,
      Form.for_update(ticket_type, :update, actor: socket.assigns.current_user)
    )
  end
end
