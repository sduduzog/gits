defmodule GitsWeb.AccountController do
  use GitsWeb, :controller

  require Ash.Query
  alias AshPhoenix.Form

  alias Gits.Dashboard.Account
  alias Gits.Storefront.Event

  plug :auth_guard
  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  defp auth_guard(conn, _) do
    if conn.assigns.current_user do
      conn
    else
      return_to = URI.encode_query(%{"return_to" => "#{conn.request_path}?#{conn.query_string}"})

      conn |> redirect(to: "/sign-in?#{return_to}") |> halt()
    end
  end

  def new(conn, _) do
    form =
      Event |> Form.for_create(:first_event, as: "event", actor: conn.assigns.current_user)

    render(assign(conn, :form, form), :new, layout: false)
  end

  def create(conn, params) do
    form =
      Form.for_create(Event, :first_event,
        as: "event",
        actor: conn.assigns.current_user
      )
      |> Form.validate(params["event"])

    if form.valid? do
      account =
        Account
        |> Ash.Changeset.for_create(:create, %{
          name: conn.assigns.current_user.display_name,
          member: %{user: conn.assigns.current_user},
          event: %{
            name: form.params["name"],
            description: form.params["description"],
            starts_at: form.params["starts_at"]
          }
        })
        |> Ash.create!(load: [:events])

      [event] = account.events

      redirect(conn, to: ~p"/accounts/#{account.id}/events/#{event.id}/settings")
    end

    render(assign(conn, :form, form), :new, layout: false)
  end

  def show(conn, _) do
    # changeset =
    #   Ash.Changeset.for_update(conn.assigns.current_user, :send_confirmation_email)
    #
    # strategy =
    #   AshAuthentication.Info.strategy!(conn.assigns.current_user, :confirm)
    #
    # {:ok, token} =
    #   AshAuthentication.AddOn.Confirmation.confirmation_token(strategy, changeset, changeset.data)
    #
    # Gits.Auth.Senders.EmailConfirmation.send(changeset.data, token, [])

    render(conn, :show)
  end

  def index(conn, params) do
    route = params["to"]

    accounts =
      Account
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
