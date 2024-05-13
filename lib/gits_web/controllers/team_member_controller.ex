defmodule GitsWeb.TeamMemberController do
  require Ash.Query
  alias Gits.Dashboard.Member
  alias Gits.Dashboard.Invite
  use GitsWeb, :controller

  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  def index(conn, params) do
    member =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(account.id == ^params["account_id"])
      |> Ash.read!()

    invites =
      Invite
      |> Ash.Query.for_read(:read, %{}, actor: member)
      |> Ash.read!()

    assign(
      conn,
      :roles,
      []
    )
    |> assign(
      :invites,
      invites
    )
    |> render(:index)
  end
end
