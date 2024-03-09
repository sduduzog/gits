defmodule GitsWeb.AccountController do
  use GitsWeb, :controller
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

  def show(conn, _) do
    events =
      Event
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(id: :desc)
      |> Gits.Events.read!()

    conn
    |> assign(:events, events)
    |> render(:show, layout: {GitsWeb.Layouts, :account})
  end

  def account_settings(conn, _) do
    conn
    |> render(:settings, layout: {GitsWeb.Layouts, :account})
  end
end
