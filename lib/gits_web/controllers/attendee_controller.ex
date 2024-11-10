defmodule GitsWeb.AttendeeController do
  alias Gits.Admissions.Attendee
  alias Gits.Dashboard.Member
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
end
