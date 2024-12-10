defmodule GitsWeb.HostLive.EditEvent do
  alias Gits.Accounts.Venue
  alias Gits.GooglePlaces
  alias Gits.Storefront.Event
  alias Gits.Storefront.TicketType
  alias Gits.Storefront.{Event, TicketType}
  alias AshPhoenix.Form
  require Ash.Query
  use GitsWeb, :live_view

  embed_templates "edit_event_templates/*"

  def mount(_params, _session, socket) do
    socket |> ok(:host_panel)
  end

  def handle_params(unsigned_params, _uri, socket) do
    user = socket.assigns.current_user

    Event
    |> Ash.Query.filter(public_id == ^unsigned_params["public_id"])
    |> Ash.Query.load([:name, :ticket_types])
    |> Ash.read_one(actor: user)
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(
          :form,
          current_form(socket.assigns.live_action, event, user)
        )
        |> show_archive_ticket_modal(unsigned_params, event, user)
        |> show_ticket_form(unsigned_params, event, user)
        |> assign_event_update(event, user)
        |> noreply()
    end
  end

  def handle_event("close", _unsigned_params, socket) do
    case socket.assigns do
      %{event: event, host: host} ->
        socket
        |> push_navigate(
          to: Routes.host_view_event_path(socket, :overview, host.handle, event.public_id),
          replace: true
        )

      %{host: host} ->
        socket
        |> push_navigate(to: Routes.host_list_events_path(socket, :drafts, host.handle))
    end
    |> noreply()
  end

  def handle_event("validate", %{"_target" => ["reset"]}, socket) do
    case socket.assigns.form.action do
      :add_ticket_type ->
        assign(
          socket,
          :form,
          Form.for_update(socket.assigns.event, :add_ticket_type, forms: [auto?: true])
          |> Form.add_form([:type], validate?: false)
        )

      :edit_ticket_type ->
        assign(
          socket,
          :form,
          Form.for_update(socket.assigns.event, :edit_ticket_type, forms: [auto?: true])
        )

      _ ->
        assign(
          socket,
          :form,
          current_form(
            socket.assigns.live_action,
            socket.assigns.event,
            socket.assigns.current_user
          )
        )
    end
    |> noreply()
  end

  def handle_event("validate", %{"address_search" => query}, socket) do
    search_term = "%#{query}%"

    matches =
      Ash.Query.filter(
        Venue,
        fragment("? ilike ? or ? ilike ?", name, ^search_term, address, ^search_term)
      )
      |> Ash.Query.limit(5)
      |> Ash.Query.load([:host])
      |> Ash.read()
      |> case do
        {:ok, matches} -> matches
        _ -> []
      end

    socket = assign(socket, :matches, matches)

    GooglePlaces.get_suggestions(query, :cache)
    |> case do
      {:ok, suggestions} -> assign(socket, :suggestions, suggestions)
      _ -> assign(socket, :suggestions, [])
    end
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(
      :form,
      Form.validate(socket.assigns.form, unsigned_params["form"],
        target: unsigned_params["_target"],
        errors: false
      )
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
         |> Form.submit(params: unsigned_params["form"])}
    end
    |> case do
      {:create, {:ok, event}} ->
        socket
        |> put_flash(:info, "Event created")
        |> push_patch(
          to:
            Routes.host_edit_event_path(
              socket,
              :location,
              socket.assigns.host.handle,
              event.public_id
            ),
          replace: true
        )

      {:update, {:ok, event}} ->
        socket
        |> put_flash(:info, "Event updated")
        |> push_patch(
          to:
            Routes.host_edit_event_path(
              socket,
              :location,
              socket.assigns.host.handle,
              event.public_id
            ),
          replace: true
        )

      {_, {:error, form}} ->
        socket |> assign(:form, form)
    end
    |> noreply()
  end

  def handle_event("create_venue", unsigned_params, socket) do
    push_navigate(socket,
      to:
        Routes.host_edit_venue_path(socket, :create, socket.assigns.host.handle, unsigned_params)
    )
    |> noreply()
  end

  def handle_event("use_venue", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> IO.inspect()
    |> case do
      {:ok, event} ->
        assign_event_update(socket, event, socket.assigns.current_user)
        |> noreply()
    end
  end

  def handle_event("remove_venue", unsigned_params, socket) do
    Form.submit(socket.assigns.remove_venue_form, params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        assign_event_update(socket, event, socket.assigns.current_user)
        |> noreply()
    end
  end

  def handle_event("tickets", unsigned_params, socket) do
    socket.assigns.form
    |> Form.submit(params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        push_patch(socket,
          to:
            Routes.host_edit_event_path(
              socket,
              :tickets,
              socket.assigns.host.handle,
              event.public_id
            ),
          replace: true
        )

      {:error, form} ->
        assign(socket, :form, form)
    end
    |> noreply()
  end

  defp current_form(:details, nil, actor) do
    Form.for_create(Event, :create, forms: [auto?: true], actor: actor)
    |> Form.add_form([:host], type: :read, validate?: false)
  end

  defp current_form(:details, event, actor) do
    event
    |> Form.for_update(:details, forms: [auto?: true], actor: actor)
  end

  defp current_form(:location, event, actor) do
    event
    |> Form.for_update(:location, forms: [auto?: true], actor: actor)
  end

  defp current_form(:tickets, event, actor) do
    event
    |> Form.for_update(:update, forms: [auto?: true], actor: actor)
  end

  defp current_form(_, _, _) do
    nil
  end

  defp show_archive_ticket_modal(
         socket,
         %{"modal" => "ticket", "archive" => ticket_id},
         event,
         actor
       ) do
    event
    |> Ash.load([ticket_types: Ash.Query.filter(TicketType, id == ^ticket_id)], actor: actor)
    |> case do
      {:ok, event} ->
        socket
        |> assign(
          :form,
          event
          |> Form.for_update(:archive_ticket_type, forms: [auto?: true], actor: actor)
        )
        |> assign(:show_archive_ticket_modal, true)
    end
  end

  defp show_archive_ticket_modal(socket, _, _, _) do
    socket
    |> assign(:show_archive_ticket_modal, false)
  end

  defp show_ticket_form(socket, %{"ticket" => "create"}, event, actor) do
    assign(socket, :show_ticket_form, true)
    |> assign(
      :form,
      event
      |> Form.for_update(:add_ticket_type, forms: [auto?: true], actor: actor)
      |> Form.add_form([:type], validate?: false)
    )
  end

  defp show_ticket_form(socket, %{"ticket" => "edit", "id" => id}, event, actor) do
    Ash.load(event, [ticket_types: [Ash.Query.filter(TicketType, id == ^id)]], actor: actor)
    |> case do
      {:ok, event} ->
        assign(socket, :show_ticket_form, true)
        |> assign(
          :form,
          Form.for_update(event, :edit_ticket_type, forms: [auto?: true], actor: actor)
        )
    end
  end

  defp show_ticket_form(socket, _, _, _) do
    assign(socket, :show_ticket_form, false)
  end

  def assign_event_update(socket, event, actor) do
    case socket.assigns.live_action do
      :details ->
        Ash.load(event, [], actor: actor)
        |> case do
          {:ok, nil} ->
            socket
            |> assign(:on_next_path, "#")

          {:ok, event} ->
            on_next_path =
              Routes.host_edit_event_path(
                socket,
                :location,
                socket.assigns.host.handle,
                event.public_id
              )

            socket
            |> assign(:on_next_path, on_next_path)
        end

      :location ->
        Ash.load(event, [:venue], actor: actor)
        |> case do
          {:ok, event} ->
            socket
            |> assign(:event_public_id, event.public_id)
            |> assign(:venue, event.venue)
            |> assign(:remove_venue_form, Form.for_update(event, :remove_venue, actor: actor))
            |> assign(
              :form,
              if(event.venue,
                do: Form.for_update(event, :location, actor: actor),
                else: Form.for_update(event, :use_venue, actor: actor)
              )
            )
        end

      :live_stream ->
        socket
    end
    |> assign_new(:matches, fn ->
      Ash.Query.limit(Venue, 5)
      |> Ash.Query.load(:host)
      |> Ash.read()
      |> case do
        {:ok, venues} -> venues
        _ -> []
      end
    end)
    |> assign_new(:suggestions, fn -> [] end)
  end

  def assign_event_update(socket, _, _) do
    socket
  end
end
