defmodule GitsWeb.HostLive.ViewEvent do
  alias Gits.Storefront.Ticket
  alias Gits.Accounts.Host
  alias Gits.Storefront.{Event}
  use GitsWeb, :live_view
  require Ash.Query

  import GitsWeb.HostComponents

  embed_templates "view_event_templates/*"

  @event_load_keys [
    :utc_starts_at,
    :start_date_invalid?,
    :end_date_invalid?,
    :venue_invalid?,
    :venue,
    :unique_views,
    :total_orders,
    :admissions,
    :total_revenue,
    :actual_revenue,
    ticket_types: [
      :active_tickets_count,
      tickets: Ash.Query.filter(Ticket, not is_nil(attendee)) |> Ash.Query.load(:attendee)
    ]
  ]

  def mount(%{"handle" => handle, "public_id" => public_id}, _, socket) do
    user = socket.assigns.current_user

    Ash.load(
      user,
      [
        hosts:
          Ash.Query.filter(Host, handle == ^handle)
          |> Ash.Query.load(
            events:
              Ash.Query.filter(Event, public_id == ^public_id) |> Ash.Query.load(@event_load_keys)
          )
      ],
      actor: user
    )
    |> case do
      {:ok, %{hosts: [%{events: [event]}]}} ->
        ticket_types =
          event.ticket_types
          |> Enum.map(fn type ->
            price =
              if Decimal.gt?(type.price, Decimal.new("0")), do: "R #{type.price}", else: "Free"

            per_user = "#{type.limit_per_user} p.p"

            Map.merge(type, %{tags: [price, per_user]})
          end)

        assign(socket, :event, event)
        |> assign_issues()
        |> assign_attendees()
        |> assign(:ticket_types, ticket_types)
        |> assign(:page_title, "Events / #{event.name}")
        |> assign(:section, event.name)
        |> ok(:host)
    end
  end

  def handle_params(_, _, socket) do
    socket |> noreply()
  end

  def handle_event("publish", _, socket) do
    Ash.Changeset.for_update(socket.assigns.event, :publish, %{})
    |> Ash.update(actor: socket.assigns.current_user, load: @event_load_keys)
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign_issues()
        |> noreply()
    end
  end

  def handle_event("archive", _, socket) do
    Ash.Changeset.for_destroy(socket.assigns.event, :destroy)
    |> Ash.destroy(actor: socket.assigns.current_user)

    socket |> noreply()
  end

  defp can_publish?(event, actor) do
    Ash.Changeset.for_update(event, :publish, %{})
    |> Ash.can?(actor)
  end

  defp assign_attendees(socket) do
    # name 
    # rsvp time 
    # admitted time
    # ticket id (copyable url) 
    # socket |> assign(:attendees, socket.assigns.event.attendees)
    attendees =
      Enum.flat_map(socket.assigns.event.ticket_types, fn type ->
        Enum.map(type.tickets, fn ticket ->
          %{
            name: ticket.attendee.name,
            ticket: type.name,
            rsvp_confirmed_at: ticket.rsvp_confirmed_at,
            admitted_at: ticket.admitted_at
          }
        end)
      end)

    socket |> assign(:attendees, attendees)
  end

  defp assign_issues(socket) do
    socket |> assign(:issues, list_issues(socket.assigns.event))
  end

  defp list_issues(%Event{state: :draft} = event) do
    [
      if(event.start_date_invalid?, do: "Start date should not be in the past", else: false),
      if(event.end_date_invalid?, do: "End date should not be before the start date", else: false),
      if(event.venue_invalid?, do: "The event location is not set", else: false)
    ]
    |> Enum.filter(& &1)
  end

  defp list_issues(_) do
    []
  end
end
