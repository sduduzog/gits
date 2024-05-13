defmodule GitsWeb.TeamInviteController do
  use GitsWeb, :controller

  require Ash.Query

  alias Gits.Dashboard.Invite
  alias Gits.Dashboard.Account
  alias Gits.Dashboard.Member
  alias AshPhoenix.Form

  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  def show(conn, params) do
    Ash.Query.for_read(Invite, :read)
    |> Ash.Query.filter(id: params["id"])
    |> Ash.read_one()
    |> case do
      {:ok, invite} when not is_nil(invite) ->
        conn
        |> assign(
          :invite,
          invite
        )
        |> render(:show, layout: false)

      {:ok, nil} ->
        raise GitsWeb.Exceptions.AccountNotFoundError, "no account found"
    end
  end

  def update(%{method: "PATCH"} = conn, _params) do
    conn |> render(:show, layout: false)
  end

  def update(%{method: "PUT"} = conn, params) do
    user = conn.assigns.current_user

    account =
      Account
      |> Ash.get!(params["account_id"], actor: user)

    invite =
      Invite
      |> Ash.get!(params["id"], actor: user)

    Member
    |> Ash.Changeset.for_create(
      :accept_invitation,
      %{account: account, user: user, invite: invite},
      actor: user
    )
    |> IO.inspect()

    conn |> render(:show, layout: false)
  end

  def update(conn, params) do
    conn
    |> assign(
      :invite,
      Ash.Query.for_read(Invite, :read)
      |> Ash.Query.filter(id: params["id"])
      |> Gits.Accounts.read_one!()
    )
    |> render(:show, layout: false)
  end

  def delete(conn, params) do
    Ash.Query.for_read(Invite, :read, actor: conn.assigns.current_user)
    |> Ash.Query.filter(id: params["id"])
    |> Gits.Accounts.read_one!()
    |> Ash.Changeset.for_destroy(:destroy, actor: conn.assigns.current_user)
    |> Gits.Accounts.destroy()

    redirect(conn, to: ~p"/accounts/#{params["account_id"]}/team")
  end

  def new(conn, params) do
    member =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(account.id == ^params["account_id"])
      |> Ash.read!()

    conn
    |> assign(
      :form,
      Form.for_create(Invite, :create,
        as: "invite",
        actor: member
      )
    )
    |> assign(:action, ~p"/accounts/#{params["account_id"]}/invites")
    |> render(:new)
  end

  def create(conn, params) do
    member =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: conn.assigns.current_user)
      |> Ash.Query.filter(account.id == ^params["account_id"])
      |> Ash.read!()

    account =
      Ash.Query.for_read(Account, :read)
      |> Ash.Query.filter(id: params["account_id"])
      |> Ash.read_one!()

    Form.for_create(Invite, :create,
      as: "invite",
      actor: member
    )
    |> Form.validate(
      Map.merge(params["invite"], %{
        "account" => account
      })
    )
    |> case do
      form when form.valid? ->
        with {:ok, _} <- Form.submit(form) do
          conn
          |> redirect(to: ~p"/accounts/#{params["account_id"]}/team")
        else
          all ->
            IO.inspect(all)

            conn
            |> assign(:form, form)
            |> assign(:action, ~p"/accounts/#{params["account_id"]}/invites")
            |> render(:new)
        end

      form ->
        conn
        |> assign(:form, form)
        |> assign(:action, ~p"/accounts/#{params["account_id"]}/invites")
        |> render(:new)
    end
  end

  def resend_invite(conn, params) do
    Invite
    |> Ash.get!(params["team_invite_id"])
    |> Ash.Changeset.for_update(:resend, %{}, actor: nil)
    |> Ash.update!()
    |> IO.inspect()

    IO.inspect(params)
    conn |> redirect(to: ~p"/accounts/#{params["account_id"]}/team")
  end
end
