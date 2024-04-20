defmodule GitsWeb.AccountController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Storefront.Event
  alias AshPhoenix.Form

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

    assign(conn, :form, form) |> render(:new, layout: false)
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

  def show(conn, _) do
    render(conn, :show)
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

  # def index(conn, params) do
  #   route = params["to"]
  #
  #   accounts =
  #     Account
  #     |> Ash.Query.sort(created_at: :desc)
  #     |> Ash.Query.load(roles: Role |> Ash.Query.filter(user_id: conn.assigns.current_user.id))
  #
  #   with {:ok, %{accounts: accounts}} <-
  #          Ash.load(conn.assigns.current_user, accounts: accounts) do
  #     case accounts do
  #       [head | []] when not is_nil(route) ->
  #         redirect(conn, to: ~p"/accounts/#{head.id}/" <> route)
  #
  #       [head | []] ->
  #         redirect(conn, to: ~p"/accounts/#{head.id}")
  #
  #       list ->
  #         assign(conn, :accounts, list)
  #         |> render(:index, layout: false)
  #     end
  #   else
  #     _ -> render(conn, :index, layout: false)
  #   end
  # end
  #
  # def show(conn, params) do
  #   account =
  #     Ash.Query.filter(Account, id: params["account_id"])
  #     |> Ash.read_one!(actor: conn.assigns.current_user)
  #
  #   events =
  #     Ash.Query.filter(Event, account.id == ^account.id)
  #     |> Ash.read!(actor: conn.assigns.current_user)
  #
  #   conn
  #   |> assign(:events, events)
  #   |> render(:show, layout: {GitsWeb.Layouts, :account})
  # end
  #
  # def account_settings(conn, _) do
  #   conn
  #   |> render(:settings, layout: {GitsWeb.Layouts, :account})
  # end
  #
  # def team(conn, params) do
  #   conn
  #   |> assign(
  #     :account,
  #     Account
  #     |> Ash.Query.for_read(:read, actor: conn.assigns.current_user)
  #     |> Ash.Query.filter(id: params["account_id"])
  #     |> Ash.read_one!()
  #     |> Ash.load!(roles: [:user])
  #   )
  #   |> render(:team, layout: {GitsWeb.Layouts, :account})
  # end
end
