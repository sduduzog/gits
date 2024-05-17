defmodule GitsWeb.AccountController do
  use GitsWeb, :controller

  require Ash.Query
  alias AshPhoenix.Form
  alias Gits.Dashboard.Member
  alias Gits.Storefront.Event

  alias Gits.Dashboard.Account

  plug :auth_guard
  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  defp auth_guard(conn, _) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> redirect(to: ~p"/register?return_to=#{conn.request_path <> "?" <> conn.query_string}")
      |> halt()
    end
  end

  def new(conn, _) do
    form =
      Form.for_create(Account, :create,
        forms: [event: [resource: Event, create_action: :create]],
        as: "account",
        actor: conn.assigns.current_user
      )
      |> Form.add_form(:event, validate?: false)

    conn |> put_layout(html: :thin) |> assign(:form, form) |> render(:new)
  end

  def create(conn, params) do
    user = conn.assigns.current_user

    form =
      Form.for_create(Account, :create,
        as: "account",
        forms: [event: [resource: Event, create_action: :create]],
        actor: user
      )
      |> Form.add_form(:event, validate?: false)
      |> Form.validate(
        Map.merge(params["account"], %{member: %{user: user}, name: user.display_name})
      )

    with true <- form.valid?, {:ok, %{events: [event]} = account} <- Form.submit(form) do
      redirect(conn, to: ~p"/accounts/#{account.id}/events/#{event.id}/settings")
    else
      _ ->
        assign(conn, :form, form) |> render(:new, layout: false)
    end
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

  def index(conn, params) do
    route = params["to"]

    accounts =
      Ash.Query.for_read(Account, :read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(members.user.id == ^conn.assigns.current_user.id)
      |> Ash.Query.load(:members)
      |> Ash.read!()

    case accounts do
      [head | []] when not is_nil(route) ->
        redirect(conn, to: ~p"/accounts/#{head.id}/" <> route)

      [head | []] ->
        redirect(conn, to: ~p"/accounts/#{head.id}")

      list ->
        assign(conn, :accounts, list)
        |> render(:index, layout: false)
    end
  end

  def next(conn, _) do
    conn
    |> assign(:nav, ["Overview"])
    |> render()
  end
end
