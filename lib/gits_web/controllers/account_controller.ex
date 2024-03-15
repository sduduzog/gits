defmodule GitsWeb.AccountController do
  use GitsWeb, :controller
  require Ash.Query
  alias Gits.Accounts.Account
  alias Gits.Accounts
  alias Gits.Events.Event

  plug GitsWeb.AuthGuard

  def index(%{assigns: %{current_user: user}} = conn, %{"to" => route}) do
    Accounts.load!(user, :accounts)
    |> Map.get(:accounts)
    |> case do
      [head | []] ->
        redirect(conn, to: ~p"/accounts/#{head.id}/" <> route)

      _ ->
        render(conn, :index, layout: false)
    end
  end

  def index(%{assigns: %{current_user: user}} = conn, _) do
    Accounts.load!(user, :accounts)
    |> Map.get(:accounts)
    |> case do
      [head | []] -> redirect(conn, to: ~p"/accounts/#{head.id}")
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
