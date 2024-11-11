defmodule GitsWeb.AccountController do
  use GitsWeb, :controller

  require Ash.Query
  alias AshPhoenix.Form
  alias Gits.Dashboard.Member

  alias Gits.Dashboard.Account

  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  def new(conn, _) do
    form =
      Form.for_create(Account, :create,
        as: "account",
        actor: conn.assigns.current_user
      )

    conn |> put_layout(html: :app) |> assign(:form, form) |> render(:new)
  end

  def show(conn, params) do
    account =
      Ash.Query.for_read(Account, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(id: params["id"])
      |> Ash.Query.load(
        members:
          Ash.Query.for_read(Member, :read)
          |> Ash.Query.filter(user.id == ^conn.assigns.current_user.id)
      )
      |> Ash.read_one!()

    unless account do
      raise GitsWeb.Exceptions.NotFound, "no account found"
    end

    conn
    |> assign(:members, account.members)
    |> render(:show)
  end

  def next(conn, _) do
    conn
    |> assign(:nav, ["Overview", "Events", "Team"])
    |> render()
  end
end
