defmodule GitsWeb.AttendeeController do
  alias Gits.Admissions.Attendee
  alias Gits.Dashboard.Member
  alias Gits.Storefront.Event
  alias Gits.Storefront.TicketInstance
  require Ash.Query
  use GitsWeb, :controller

  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

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
    member =
      Ash.Query.for_read(Member, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.read_first!()

    attendees =
      Ash.Query.for_read(Attendee, :read, %{}, actor: member)
      |> Ash.Query.filter(event.id == ^params["event_id"])
      |> Ash.Query.load(:user)
      |> Ash.read!()

    assign(conn, :attendees, attendees)
    |> render(:index)
  end

  def new(conn, params) do
    [id] = Sqids.new!() |> Sqids.decode!(params["code"])

    member =
      Ash.Query.for_read(Member, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.read_first!()

    event =
      Ash.Query.for_read(Event, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(id: params["event_id"])
      |> Ash.Query.load(:masked_id)
      |> Ash.read_one!()

    instance =
      Ash.Query.for_read(TicketInstance, :read, %{}, actor: member)
      |> Ash.Query.filter(id: id)
      |> Ash.Query.filter(ticket.event.id == ^params["event_id"])
      |> Ash.Query.load(customer: [:user])
      |> Ash.read_one!()

    errors =
      if instance do
        Ash.Changeset.for_create(Attendee, :create, %{
          user: instance.customer.user,
          event: event,
          instance: instance
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
