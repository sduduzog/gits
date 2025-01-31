defmodule GitsWeb.HostLive.Events do
  alias Gits.Accounts.Venue
  alias Gits.GooglePlaces
  alias Gits.Bucket.Image
  alias Gits.Storefront.TicketType
  alias AshPhoenix.Form
  alias Gits.Accounts.Host
  alias Gits.Storefront.Event
  require Ash.Query
  use GitsWeb, :live_view
  import GitsWeb.HostComponents

  embed_templates "events_templates/*"

  def mount(params, _, socket) do
    Ash.Query.filter(Host, handle == ^params["handle"])
    |> Ash.Query.load(:payment_method_ready?)
    |> Ash.read_one(actor: socket.assigns.current_user)
    |> case do
      {:ok, %Host{} = host} ->
        socket
        |> assign(:host, host)
        |> assign(:uploaded_files, [])
        |> assign(:poster, nil)
        |> allow_upload(:poster,
          accept: ~w(.jpg .jpeg .png .webp),
          max_entries: 1,
          max_file_size: 1_048_576 * 2,
          auto_upload: true,
          progress: &handle_upload_progress/3
        )
        |> GitsWeb.HostLive.assign_sidebar_items(__MODULE__, host)
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
        |> assign_new(:venue_suggestions, fn -> [] end)
        |> assign_new(:venue, fn -> nil end)
        |> ok(:dashboard)
    end
  end

  def handle_params(%{"public_id" => public_id}, _, socket) do
    socket =
      socket
      |> assign(:details_form, nil)

    socket =
      Ash.load(
        socket.assigns.host,
        [
          events:
            Ash.Query.filter(Event, public_id == ^public_id)
            |> Ash.Query.load([
              :start_date_invalid?,
              :end_date_invalid?,
              :poster_invalid?,
              :venue_invalid?,
              :ticket_types,
              :venue
            ])
        ],
        actor: socket.assigns.current_user
      )
      |> case do
        {:ok, %{events: [event]}} ->
          issues_count =
            [
              event.start_date_invalid?,
              event.end_date_invalid?,
              event.poster_invalid?,
              event.venue_invalid?
            ]
            |> Enum.filter(& &1)
            |> IO.inspect()

          event_has_issues? = event.state == :draft and Enum.count(issues_count) > 0

          can_publish? =
            Ash.Changeset.for_update(event, :publish)
            |> Ash.can?(socket.assigns.current_user)

          socket
          |> assign(:can_publish?, can_publish?)
          |> assign(:start_date_invalid?, event.start_date_invalid?)
          |> assign(:end_date_invalid?, event.end_date_invalid?)
          |> assign(:poster_invalid?, event.poster_invalid?)
          |> assign(:venue_invalid?, event.venue_invalid?)
          |> assign(:venue, event.venue)
          |> assign(
            :issues_count,
            issues_count
            |> Enum.filter(& &1)
            |> Enum.count()
          )
          |> assign(:event_has_issues?, event_has_issues?)
          |> assign(:ticket_types, event.ticket_types)
          |> assign(:event, event)
          |> assign(:page_title, "Events / #{event.name}")
      end

    case socket.assigns.live_action do
      :dashboard ->
        Ash.load(
          socket.assigns.host,
          [
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
          ],
          actor: socket.assigns.current_user
        )
        |> case do
          {:ok, %{events: [event]}} ->
            can_publish? =
              Ash.Changeset.for_update(event, :publish)
              |> Ash.can?(socket.assigns.current_user)

            socket
            |> assign(:event, event)
            |> assign(:can_publish?, can_publish?)
        end

      :details ->
        Ash.load(
          socket.assigns.host,
          [
            events:
              Ash.Query.filter(Event, public_id == ^public_id)
              |> Ash.Query.load([
                :start_date_invalid?,
                :end_date_invalid?,
                :poster_invalid?,
                :venue_invalid?,
                :has_paid_tickets?,
                :total_ticket_types,
                :ticket_types,
                :venue,
                poster: :url
              ])
          ],
          actor: socket.assigns.current_user
        )
        |> case do
          {:ok, %{events: [event]}} ->
            socket
            |> assign(:event, event)
            |> assign(
              :details_form,
              Form.for_update(event, :details,
                actor: socket.assigns.current_user,
                forms: [auto?: true]
              )
            )
        end

      :tickets ->
        Ash.load(
          socket.assigns.host,
          [
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
          ],
          actor: socket.assigns.current_user
        )
        |> case do
          {:ok, %{events: [event]}} ->
            socket
            |> assign(:event, event)
            |> assign(
              :tickets_form,
              Form.for_create(TicketType, :create,
                actor: socket.assigns.current_user,
                forms: [auto?: true]
              )
              |> Form.add_form([:event], type: :read, validate?: false, data: event)
            )
        end

      :admissions ->
        socket

      :settings ->
        Ash.load(
          socket.assigns.host,
          [
            events:
              Ash.Query.filter(Event, public_id == ^public_id) |> Ash.Query.load([:webhooks])
          ],
          actor: socket.assigns.current_user
        )
        |> case do
          {:ok, %{events: [event]}} ->
            socket
            |> assign(:event, event)
            |> assign(
              :tickets_form,
              Form.for_create(TicketType, :create,
                actor: socket.assigns.current_user,
                forms: [auto?: true]
              )
              |> Form.add_form([:event], type: :read, validate?: false, data: event)
            )
        end
    end
    |> noreply()
  end

  def handle_params(unsigned_params, _, socket) do
    socket =
      socket
      |> assign(:details_submit_action, "create")
      |> assign(:events, [])
      |> assign(:event_has_issues?, false)
      |> assign(:ticket_types, [])
      |> assign(:page_title, "Events")

    case socket.assigns.live_action do
      # not @host.payment_method_ready? and Enum.any?(@ticket_types, &Decimal.gt?(&1.price, 0))
      :index ->
        Ash.load(socket.assigns.host, [:events], actor: socket.assigns.current_user)
        |> case do
          {:ok, %{events: events}} ->
            socket
            |> assign(:events, events)
        end

      :details ->
        socket
        |> assign(:handle, unsigned_params["handle"])
        |> assign(:host_name, socket.assigns.host.name)
        |> assign(:events, [])
        |> assign(:issues_count, 0)
        |> assign(:ticket_types, [])
        |> assign(
          :details_form,
          Form.for_create(Event, :create,
            forms: [auto?: true],
            actor: socket.assigns.current_user
          )
          |> Form.add_form([:host], type: :read, validate?: false, data: socket.assigns.host)
        )
        |> assign(:event, nil)
    end
    |> noreply()
  end

  def handle_event("validate_details_form", unsigned_params, socket) do
    socket
    |> assign(:details_form, Form.validate(socket.assigns.details_form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("submit_details_form", unsigned_params, socket) do
    case socket.assigns.details_form.type do
      :create ->
        Form.submit(socket.assigns.details_form, params: unsigned_params["form"])
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
            |> assign(:details_form, form)
            |> noreply()
        end

      :update ->
        Form.submit(socket.assigns.details_form,
          params: unsigned_params["form"],
          action_opts: [
            load: [
              :start_date_invalid?,
              :end_date_invalid?,
              :poster_invalid?,
              :venue_invalid?,
              poster: [:url]
            ]
          ]
        )
        |> case do
          {:ok, event} ->
            issues_count =
              [
                event.start_date_invalid?,
                event.end_date_invalid?,
                event.poster_invalid?,
                event.venue_invalid?
              ]
              |> Enum.filter(& &1)

            event_has_issues? = event.state == :draft and Enum.count(issues_count) > 0

            socket
            |> assign(:event, event)
            |> assign(:start_date_invalid?, event.start_date_invalid?)
            |> assign(:end_date_invalid?, event.end_date_invalid?)
            |> assign(:poster_invalid?, event.poster_invalid?)
            |> assign(:venue_invalid?, event.venue_invalid?)
            |> assign(:venue, event.venue)
            |> assign(
              :issues_count,
              issues_count
              |> Enum.filter(& &1)
              |> Enum.count()
            )
            |> assign(:event_has_issues?, event_has_issues?)
            |> assign(
              :details_form,
              Form.for_update(event, :details,
                actor: socket.assigns.current_user,
                forms: [auto?: true]
              )
            )
            |> noreply()

          {:error, form} ->
            socket
            |> assign(:details_form, form)
            |> noreply()
        end
    end
  end

  def handle_event("publish_event", _, socket) do
    Ash.Changeset.for_update(socket.assigns.event, :publish, %{})
    |> Ash.update(actor: socket.assigns.current_user, load: [])
    |> case do
      {:ok, event} ->
        can_publish? =
          Ash.Changeset.for_update(event, :publish)
          |> Ash.can?(socket.assigns.current_user)

        socket
        |> assign(:event, event)
        |> assign(:can_publish?, can_publish?)
        |> noreply()
    end
  end

  def handle_event("venue_search", %{"query" => query}, socket) do
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
        |> assign(:venue_suggestions, suggestions)
    end
    |> noreply()
  end

  def handle_event("pre_choose_venue", _, socket) do
    venue =
      Form.get_form(socket.assigns.details_form, :venue)
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
      host: %{id: socket.assigns.host.id}
    })
    |> Ash.create(actor: socket.assigns.current_user)
    |> case do
      {:ok, venue} -> update_form_with_venue(socket, venue)
    end
    |> noreply()
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

  def handle_event("delete_webhook", %{"id" => id}, socket) do
    webhook =
      socket.assigns.webhooks
      |> Enum.find(&(&1.id == id))

    Ash.Changeset.for_destroy(webhook, :destroy)
    |> Ash.destroy(actor: socket.assigns.current_user)
    |> case do
      :ok ->
        socket
        |> assign(:webhooks, Enum.filter(socket.assigns.webhooks, &(&1.id != webhook.id)))
        |> noreply()
    end
  end

  def handle_event("manage_webhook", %{"id" => id}, socket) do
    webhook =
      socket.assigns.webhooks
      |> Enum.find(&(&1.id == id))

    socket
    |> assign(
      :form,
      Form.for_update(webhook, :update, actor: socket.assigns.current_user)
    )
    |> noreply()
  end

  def handle_event("manage_webhook", _, socket) do
    socket
    |> assign(
      :form,
      Form.for_create(Webhook, :create, actor: socket.assigns.current_user, forms: [auto?: true])
      |> Form.add_form(:event, type: :read, validate?: false)
    )
    |> noreply()
  end

  def handle_event("validate_webhook", unsigned_params, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("submit_webhook", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, webhook} ->
        socket
        |> assign(:webhooks, [webhook] ++ socket.assigns.webhooks)
        |> assign(:form, Form.for_update(webhook, :update, actor: socket.assigns.current_user))
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  def handle_event("archive_event", _, socket) do
    Ash.Changeset.for_destroy(socket.assigns.event, :destroy)
    |> Ash.destroy(actor: socket.assigns.current_user)
    |> case do
      :ok -> socket |> redirect(to: ~p"/hosts/#{socket.assigns.host.handle}/events")
    end
    |> noreply()
  end

  defp update_form_with_venue(socket, venue) do
    form =
      if Form.has_form?(socket.assigns.details_form, [:venue]) do
        Form.update_form(socket.assigns.details_form, [:venue], fn form ->
          Form.set_data(form, venue)
        end)
      else
        Form.add_form(socket.assigns.details_form, [:venue],
          type: :read,
          data: venue
        )
      end

    assign(socket, :details_form, form)
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

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  defp handle_upload_progress(:poster, entry, socket) do
    if entry.done? do
      [image] =
        consume_uploaded_entries(socket, :poster, fn %{path: path}, _entry ->
          Ash.Changeset.for_create(Image, :poster, %{path: path, host: socket.assigns.host},
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
        if Form.has_form?(socket.assigns.details_form, [:poster]) do
          Form.update_form(socket.assigns.details_form, [:poster], fn form ->
            Form.set_data(form, image)
          end)
        else
          Form.add_form(socket.assigns.details_form, [:poster],
            type: :read,
            data: image
          )
        end

      socket
      |> assign(:details_form, form)
      |> noreply()
    else
      socket |> noreply()
    end
  end
end
