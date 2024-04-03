defmodule GitsWeb.AttendeeController do
  alias Gits.Events.Attendee
  alias Gits.Events.TicketInstance
  require Ash.Query
  use GitsWeb, :controller

  plug :assign_params

  def assign_params(conn, _) do
    case conn.path_info do
      [_, account_id, _, event_id | _] ->
        conn
        |> assign(:account_id, account_id)
        |> assign(:event_id, event_id)

      [_, account_id, _] ->
        conn
        |> assign(:account_id, account_id)

      _ ->
        conn
    end
  end

  def index(conn, params) do
    attendees =
      Ash.Query.filter(Attendee, event.id == ^params["event_id"])
      |> Ash.read!()

    assign(conn, :attendees, attendees)
    |> render(:index, layout: {GitsWeb.Layouts, :event})
  end

  def new(conn, params) do
    instance =
      Ash.Query.filter(TicketInstance, id: params["code"])
      |> Ash.Query.filter(ticket.event.id == ^params["event_id"])
      |> Ash.Query.load(:user)
      |> Ash.read_one!()

    errors =
      if instance do
        Ash.Changeset.for_create(Attendee,:create, %{
          name: instance.user.display_name,
          email: instance.user.email,
          event_id: params["event_id"],
          instance_id: instance.id
        })
        |> Ash.create(actor: conn.assigns.current_user)
        |> case do
          {:error, %Ash.Error.Invalid{} = invalid} ->
            invalid.errors

          _ ->
            nil
        end
      else
        nil
      end

    conn
    |> assign(:instance, instance)
    |> assign(:errors, errors)
    |> render(:new, layout: false)
  end
end
