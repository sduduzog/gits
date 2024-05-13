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
    user = conn.assigns.current_user

    member =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(account.id == ^params["account_id"] and user.id == ^user.id)
      |> Ash.read_one!()

    members =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: member)
      |> Ash.Query.filter(account.id == ^params["account_id"])
      |> Ash.Query.load(:user)
      |> Ash.read!()

    invites =
      Invite
      |> Ash.Query.for_read(:read, %{}, actor: member)
      |> Ash.Query.filter(state == :sent)
      |> Ash.read!()

    assign(
      conn,
      :members,
      members
    )
    |> assign(
      :invites,
      invites
    )
    |> render(:index)
  end
end
