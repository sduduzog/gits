defmodule GitsWeb.HostLive.EditEvent do
  alias Gits.Accounts.Venue
  alias Gits.GooglePlaces
  alias Gits.Storefront.Event
  alias Gits.Storefront.{Event, EventCategory}
  alias AshPhoenix.Form
  require Ash.Query
  use GitsWeb, :live_view

  embed_templates "edit_event_templates/*"

  def mount(_params, _session, socket) do
    socket |> ok(:host_panel)
  end

  def handle_params(%{"public_id" => public_id}, _uri, socket) do
    user = socket.assigns.current_user

    Ash.Query.filter(Event, public_id == ^public_id)
    |> Ash.Query.load([:name, :ticket_types])
    |> Ash.read_one(actor: user)
    |> case do
      {:ok, event} ->
        socket
        |> assign_event_update(event, user)
        |> noreply()
    end
  end

  def handle_params(_unsigned_params, _uri, socket) do
    user = socket.assigns.current_user

    assign(socket, :event, nil)
    |> assign_event_update(nil, user)
    |> noreply()
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

  def handle_event("validate", %{"form" => _} = unsigned_params, socket) do
    socket
    |> assign(
      :form,
      Form.validate(socket.assigns.form, unsigned_params["form"],
        target: unsigned_params["_target"],
        only_touched?: true,
        errors: false
      )
    )
    |> noreply()
  end

  def handle_event("validate", _, socket) do
    socket
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        push_patch(socket,
          to:
            if(socket.assigns.on_next_path,
              do: socket.assigns.on_next_path,
              else:
                Routes.host_edit_event_path(
                  socket,
                  :location,
                  socket.assigns.host.handle,
                  event.public_id
                )
            ),
          replace: true
        )
        |> noreply()
    end
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

  def handle_event("location", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        push_patch(socket,
          to:
            Routes.host_edit_event_path(
              socket,
              :description,
              socket.assigns.host.handle,
              event.public_id
            ),
          replace: true
        )
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

  def assign_event_update(socket, event, actor) do
    case socket.assigns.live_action do
      :details ->
        Ash.load(event, [], actor: actor)
        |> case do
          {:ok, nil} ->
            socket
            |> assign(
              :form,
              Form.for_create(Event, :create, forms: [auto?: true], actor: actor)
              |> Form.add_form([:host], type: :read, validate?: false)
            )
            |> assign(:on_next_path, nil)

          {:ok, event} ->
            on_next_path =
              Routes.host_edit_event_path(
                socket,
                :location,
                socket.assigns.host.handle,
                event.public_id
              )

            socket
            |> assign(:form, Form.for_update(event, :details, forms: [auto?: true], actor: actor))
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
            |> assign(
              :on_next_path,
              Routes.host_edit_event_path(
                socket,
                :description,
                socket.assigns.host.handle,
                event.public_id
              )
            )
        end

      :tickets ->
        assign(socket, :form, Form.for_update(event, :details, actor: actor))
        |> assign(:event, event)
        |> assign(
          :on_next_path,
          Routes.host_edit_event_path(
            socket,
            :tickets,
            socket.assigns.host.handle,
            event.public_id
          )
        )
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
    |> assign_new(:event_public_id, fn -> if is_nil(event), do: nil, else: event.public_id end)
  end

  def assign_event_update(socket, _, _) do
    socket
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
