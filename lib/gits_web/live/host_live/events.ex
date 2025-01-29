defmodule GitsWeb.HostLive.Events do
  alias Gits.Bucket.Image
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
        |> ok(:host)
    end
  end

  # def mount(%{"public_id" => public_id, "handle" => handle}, _session, socket) do
  #   Ash.Query.filter(Host, handle == ^handle)
  #   |> Ash.Query.load([
  #     :payment_method_ready?,
  #     events:
  #       Ash.Query.filter(Event, public_id == ^public_id)
  #       |> Ash.Query.load([
  #         :start_date_invalid?,
  #         :end_date_invalid?,
  #         :poster_invalid?,
  #         :venue_invalid?,
  #         :has_paid_tickets?,
  #         :total_ticket_types,
  #         :ticket_types
  #       ])
  #   ])
  #   |> Ash.read_one(actor: socket.assigns.current_user)
  #   |> case do
  #     {:ok, %Host{events: [event]} = host} ->
  #       IO.inspect(event)
  #
  #       socket
  #       |> assign(:host_name, host.name)
  #       |> assign(:payment_method_ready?, host.payment_method_ready?)
  #       |> assign(:event, event)
  #       |> assign(:start_date_invalid?, event.start_date_invalid?)
  #       |> assign(:end_date_invalid?, event.end_date_invalid?)
  #       |> assign(:poster_invalid?, event.poster_invalid?)
  #       |> assign(:venue_invalid?, event.venue_invalid?)
  #       |> assign(
  #         :issues_count,
  #         [
  #           event.start_date_invalid?,
  #           event.end_date_invalid?,
  #           event.poster_invalid?,
  #           event.venue_invalid?
  #         ]
  #         |> Enum.filter(& &1)
  #         |> Enum.count()
  #       )
  #       |> assign(:ticket_types, event.ticket_types)
  #       |> assign(
  #         :tickets_form,
  #         Form.for_create(TicketType, :create,
  #           actor: socket.assigns.current_user,
  #           forms: [auto?: true]
  #         )
  #         |> Form.add_form([:event], type: :read, validate?: false, data: event)
  #       )
  #       |> assign(:host, host)
  #       |> ok(:host)
  #   end
  # end
  #
  # def mount(%{"handle" => handle}, _session, socket) do
  #   socket =
  #     case socket.assigns.live_action do
  #       :details ->
  #         socket
  #         |> assign(:details_submit_action, "do_stuff")
  #         |> assign(
  #           :details_form,
  #           Form.for_create(Event, :create,
  #             forms: [auto?: true],
  #             actor: socket.assigns.current_user
  #           )
  #           |> Form.add_form([:host], type: :read, validate?: false)
  #         )
  #         |> assign(:uploaded_files, [])
  #         |> assign(:poster, nil)
  #         |> allow_upload(:poster,
  #           accept: ~w(.jpg .jpeg .png .webp),
  #           max_entries: 1,
  #           max_file_size: 1_048_576 * 2,
  #           auto_upload: true,
  #           progress: &handle_upload_progress/3
  #         )
  #     end
  #
  #   Ash.Query.filter(Host, handle == ^handle)
  #   |> Ash.Query.load(
  #     events:
  #       Ash.Query.sort(Event, state: :desc, starts_at: :asc)
  #       |> Ash.Query.load([:name])
  #   )
  #   |> Ash.read_one(actor: socket.assigns.current_user)
  #   |> case do
  #     {:ok, %Host{events: events} = host} ->
  #       socket
  #       |> assign(:handle, host.handle)
  #       |> assign(:events, events)
  #       |> assign(:page_title, "Events")
  #       |> ok(:host)
  #   end
  # end

  def handle_params(%{"public_id" => public_id}, _, socket) do
    socket = socket |> assign(:details_form, nil)

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
              :ticket_types
            ])
        ],
        actor: socket.assigns.current_user
      )
      |> case do
        {:ok, %{events: [event]}} ->
          issues_count = [
            event.start_date_invalid?,
            event.end_date_invalid?,
            event.poster_invalid?,
            event.venue_invalid?
          ]

          event_has_issues? = Enum.count(issues_count) > 0

          socket
          |> assign(:start_date_invalid?, event.start_date_invalid?)
          |> assign(:end_date_invalid?, event.end_date_invalid?)
          |> assign(:poster_invalid?, event.poster_invalid?)
          |> assign(:venue_invalid?, event.venue_invalid?)
          |> assign(
            :issues_count,
            issues_count
            |> Enum.filter(& &1)
            |> Enum.count()
          )
          |> assign(:event_has_issues?, event_has_issues?)
          |> assign(:ticket_types, event.ticket_types)
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

      # not @host.payment_method_ready? and Enum.any?(@ticket_types, &Decimal.gt?(&1.price, 0))
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
    end
    |> noreply()
  end

  def handle_params(unsigned_params, _, socket) do
    socket =
      socket
      |> assign(:details_submit_action, "create")
      |> assign(:events, [])
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
          action_opts: [load: [poster: [:url]]]
        )
        |> case do
          {:ok, event} ->
            send(self(), {:updated_event, event})

            socket
            |> assign(:event, event)
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

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  defp handle_upload_progress(:poster, entry, socket) do
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
