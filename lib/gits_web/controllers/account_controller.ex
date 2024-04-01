defmodule GitsWeb.AccountController do
  use GitsWeb, :controller
  require Ash.Query
  alias Gits.Accounts.Role
  alias Gits.Accounts.Account

  plug GitsWeb.AuthGuard

  def index(conn, params) do
    route = params["to"]

    accounts =
      Account
      |> Ash.Query.sort(created_at: :desc)
      |> Ash.Query.load(roles: Role |> Ash.Query.filter(user_id: conn.assigns.current_user.id))

    with {:ok, %{accounts: accounts}} <-
           Gits.Accounts.load(conn.assigns.current_user, accounts: accounts) do
      case accounts do
        [head | []] when not is_nil(route) ->
          redirect(conn, to: ~p"/accounts/#{head.id}/" <> route)

        [head | []] ->
          redirect(conn, to: ~p"/accounts/#{head.id}")

        list ->
          assign(conn, :accounts, list)
          |> render(:index, layout: false)
      end
    else
      _ -> render(conn, :index, layout: false)
    end
  end

  def show(conn, params) do
    account =
      Account
      |> Ash.Query.filter(id: params["account_id"])
      |> Gits.Events.read_one!()
      |> Gits.Events.load!(:events)

    conn
    |> assign(:events, account.events)
    |> render(:show, layout: {GitsWeb.Layouts, :account})
  end

  def account_settings(conn, _) do
    conn
    |> render(:settings, layout: {GitsWeb.Layouts, :account})
  end

  def team(conn, params) do
    conn
    |> assign(
      :account,
      Account
      |> Ash.Query.for_read(:read, actor: conn.assigns.current_user)
      |> Ash.Query.filter(id: params["account_id"])
      |> Gits.Accounts.read_one!()
      |> Gits.Accounts.load!(roles: [:user])
    )
    |> render(:team, layout: {GitsWeb.Layouts, :account})
  end
end
