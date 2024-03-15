defmodule GitsWeb.TeamMemberController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Accounts
  alias Gits.Accounts.Account
  alias Gits.Accounts.Invite
  alias Gits.Accounts.Role
  alias AshPhoenix.Form

  def index(conn, params) do
    conn
    |> assign(
      :roles,
      Ash.Query.for_read(Role, :read, actor: conn.assigns.current_user)
      |> Ash.Query.filter(account_id: params["account_id"])
      |> Gits.Accounts.read!()
      |> Gits.Accounts.load!(:user)
    )
    |> render(:index, layout: {GitsWeb.Layouts, :account})
  end

  def new(conn, params) do
    conn
    |> assign(
      :form,
      Form.for_create(Invite, :create,
        api: Accounts,
        as: "invite",
        actor: conn.assigns.current_user
      )
    )
    |> assign(:action, ~p"/accounts/#{params["account_id"]}/team")
    |> render(:new, layout: {GitsWeb.Layouts, :account})
  end

  def create(conn, params) do
    conn
    |> assign(
      :form,
      Form.for_create(Invite, :create,
        api: Accounts,
        as: "invite",
        actor: conn.assigns.current_user
      )
      |> Form.validate(
        Map.merge(params["invite"], %{
          "account" =>
            Ash.Query.for_read(Account, :read)
            |> Ash.Query.filter(id: params["account_id"])
            |> Gits.Accounts.read_one!()
        })
      )
      |> IO.inspect()
    )
    |> assign(:action, ~p"/accounts/#{params["account_id"]}/team")
    |> render(:new, layout: {GitsWeb.Layouts, :account})
  end
end
