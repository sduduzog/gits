defmodule GitsWeb.AccountController do
  use GitsWeb, :controller
  require Ash.Query
  alias Gits.Events.Event
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
           Ash.load(conn.assigns.current_user, accounts: accounts) do
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
      Ash.Query.filter(Account, id: params["account_id"])
      |> Ash.read_one!(actor: conn.assigns.current_user)

    events =
      Ash.Query.filter(Event, account.id == ^account.id)
      |> Ash.read!(actor: conn.assigns.current_user)

    conn
    |> assign(:events, events)
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
      |> Ash.read_one!()
      |> Ash.load!(roles: [:user])
    )
    |> render(:team, layout: {GitsWeb.Layouts, :account})
  end
end
