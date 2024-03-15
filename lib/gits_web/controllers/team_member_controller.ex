defmodule GitsWeb.TeamMemberController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Accounts
  alias Gits.Accounts.Invite
  alias Gits.Accounts.Role

  def index(conn, params) do
    assign(
      conn,
      :roles,
      Ash.Query.for_read(Role, :read, actor: conn.assigns.current_user)
      |> Ash.Query.filter(account_id: params["account_id"])
      |> Gits.Accounts.read!()
      |> Gits.Accounts.load!(:user)
    )
    |> assign(
      :invites,
      Ash.Query.for_read(Invite, :read, actor: conn.assigns.current_user)
      |> Ash.Query.filter(account_id: params["account_id"])
      |> Gits.Accounts.read!()
    )
    |> render(:index, layout: {GitsWeb.Layouts, :account})
  end
end
