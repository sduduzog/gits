defmodule GitsWeb.HostLive.Events.Show.Details do
  require Ash.Query
  alias Gits.GooglePlaces
  alias Gits.Accounts.Venue
  alias Gits.Storefront.Event
  alias Gits.Bucket.Image
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  @load_event [
    :start_date_invalid?,
    :end_date_invalid?,
    :poster_invalid?,
    :venue_invalid?,
    :venue,
    poster: :url
  ]

  def update(assigns, socket) do
    Ash.load(assigns.event, @load_event)
    |> case do
      {:ok, %Event{} = event} ->
        socket
        |> assign(:state, event.state)
        |> assign(:venue, event.venue)
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
        |> assign(:submit_action, "update")
        |> assign(:venues, [])
        |> assign(
          :form,
          Form.for_update(event, :details, actor: assigns.current_user, forms: [auto?: true])
        )

      _ ->
        socket
        |> assign(:state, nil)
        |> assign(:submit_action, "create")
        |> assign(
          :form,
          Form.for_create(Event, :create, forms: [auto?: true], actor: assigns.current_user)
          |> Form.add_form([:host], type: :read, validate?: false)
        )
    end
    |> assign(:uploaded_files, [])
    |> assign(:poster, nil)
    |> allow_upload(:poster,
      accept: ~w(.jpg .jpeg .png .webp),
      max_entries: 1,
      max_file_size: 1_048_576 * 2,
      auto_upload: true,
      progress: &handle_progress/3
    )
    |> assign(:current_user, assigns.current_user)
    |> assign(:handle, assigns.handle)
    |> assign(:host_state, assigns.host_state)
    |> assign(:host_id, assigns.host_id)
    |> assign_new(:venues, fn _ ->
      Ash.Query.limit(Venue, 5)
      |> Ash.Query.load(:host)
      |> Ash.read()
      |> case do
        {:ok, venues} ->
          venues

        _ ->
          []
      end
    end)
    |> assign_new(:suggestions, fn -> [] end)
    |> ok()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("update", unsigned_params, socket) do
    Form.submit(socket.assigns.form,
      params: unsigned_params["form"],
      action_opts: [load: [poster: [:url]]]
    )
    |> case do
      {:ok, event} ->
        send(self(), {:updated_event, event})

        socket
        |> assign(:event, event)
        |> assign(
          :form,
          Form.for_update(event, :details,
            actor: socket.assigns.current_user,
            forms: [auto?: true]
          )
        )
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  def handle_event("create", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        socket
        |> push_patch(
          to: ~p"/hosts/#{socket.assigns.handle}/events/#{event.public_id}/details",
          replace: true
        )
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  def handle_event("search_address", %{"address_search" => query}, socket) do
    search_term = "%#{query}%"

    venues =
      Ash.Query.filter(
        Venue,
        fragment("? ilike ? or ? ilike ?", name, ^search_term, address, ^search_term)
      )
      |> Ash.Query.limit(5)
      |> Ash.Query.load([:host])
      |> Ash.read()
      |> case do
        {:ok, venues} ->
          venues

        _ ->
          []
      end

    GooglePlaces.get_suggestions(query, :cache)
    |> case do
      {:ok, suggestions} ->
        venue = socket.assigns.venue

        venue_place_id =
          if not is_nil(venue) and not is_nil(venue),
            do: venue.google_place_id,
            else: nil

        suggestions =
          Enum.filter(suggestions, &(&1.id != venue_place_id))
          |> Enum.filter(
            &(Enum.empty?(venues) or
                Enum.any?(venues, fn venue -> venue.google_place_id != &1.id end))
          )

        assign(socket, :venues, venues)
        |> assign(:suggestions, suggestions)
    end
    |> noreply()
  end

  def handle_event("pre_choose_venue", _, socket) do
    venue =
      Form.get_form(socket.assigns.form, :venue)
      |> Map.get(:data)

    venues = if is_nil(venue), do: socket.assigns.venues, else: [venue]

    socket
    |> assign(:venues, venues)
    |> noreply()
  end

  def handle_event("choose_venue", unsigned_params, socket) do
    venue = Enum.find(socket.assigns.venues, &(&1.id == unsigned_params["id"]))

    socket
    |> update_form_with_venue(venue)
    |> noreply()
  end

  def handle_event("create_venue", unsigned_params, socket) do
    Ash.Changeset.for_create(Venue, :create, %{
      google_place_id: unsigned_params["id"],
      host: %{id: socket.assigns.host_id}
    })
    |> Ash.create(actor: socket.assigns.current_user)
    |> case do
      {:ok, venue} -> update_form_with_venue(socket, venue)
    end
    |> noreply()
  end

  defp handle_progress(:poster, entry, socket) do
    if entry.done? do
      [image] =
        consume_uploaded_entries(socket, :poster, fn %{path: path}, _entry ->
          Ash.Changeset.for_create(Image, :poster, %{path: path},
            actor: socket.assigns.current_user
          )
          |> Ash.create(load: [:url])
          |> case do
            {:ok, image} ->
              {:ok, image}

            _ ->
              {:ok, nil}
          end
        end)

      form =
        if Form.has_form?(socket.assigns.form, [:poster]) do
          Form.update_form(socket.assigns.form, [:poster], fn form ->
            Form.set_data(form, image)
          end)
        else
          Form.add_form(socket.assigns.form, [:poster],
            type: :read,
            data: image
          )
        end

      socket
      |> assign(:form, form)
      |> noreply()
    else
      socket |> noreply()
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  defp update_form_with_venue(socket, venue) do
    form =
      if Form.has_form?(socket.assigns.form, [:venue]) do
        Form.update_form(socket.assigns.form, [:venue], fn form ->
          Form.set_data(form, venue)
        end)
      else
        Form.add_form(socket.assigns.form, [:venue],
          type: :read,
          data: venue
        )
      end

    assign(socket, :form, form)
  end
end
