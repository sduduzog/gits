defmodule GitsWeb.TeamInviteController do
  use GitsWeb, :controller

  require Ash.Query
  alias Gits.Accounts
  alias Gits.Accounts.Account
  alias Gits.Accounts.Invite
  alias AshPhoenix.Form

  def show(conn, params) do
    Ash.Query.for_read(Invite, :read)
    |> Ash.Query.filter(id: params["id"])
    |> Ash.Query.filter(status: :pending)
    |> Gits.Accounts.read_one()
    |> case do
      {:ok, invite} when not is_nil(invite) ->
        conn
        |> assign(
          :invite,
          invite
        )

      {:ok, nil} ->
        raise GitsWeb.Exceptions.AccountNotFoundError, "no account found"
    end
  end

  def update(%{method: "PATCH"} = conn, params) do
    IO.puts("patching")

    conn
    |> assign(
      :invite,
      Ash.Query.for_read(Invite, :read)
      |> Ash.Query.filter(id: params["id"])
      |> Gits.Accounts.read_one!()
    )
    |> render(:show, layout: false)
  end

  def update(%{method: "PUT"} = conn, params) do
    Ash.Query.for_read(Invite, :read)
    |> Ash.Query.filter(id: params["id"])
    |> Gits.Accounts.read_one!()
    |> Ash.Changeset.for_update(:accept)
    |> Gits.Accounts.update!(actor: conn.assigns.current_user)

    redirect(conn, to: ~p"/accounts/#{params["account_id"]}")
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
    conn
    |> assign(
      :form,
      Form.for_create(Invite, :create,
        api: Accounts,
        as: "invite",
        actor: conn.assigns.current_user
      )
    )
    |> assign(:action, ~p"/accounts/#{params["account_id"]}/invites")
    |> render(:new, layout: {GitsWeb.Layouts, :account})
  end

  def create(conn, params) do
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
    |> case do
      form when form.valid? ->
        with {:ok, _} <- Form.submit(form) do
          conn
          |> redirect(to: ~p"/accounts/#{params["account_id"]}/team")
        else
          _ ->
            conn
            |> assign(:form, form)
            |> assign(:action, ~p"/accounts/#{params["account_id"]}/invites")
            |> render(:new, layout: {GitsWeb.Layouts, :account})
        end

      form ->
        conn
        |> assign(:form, form)
        |> assign(:action, ~p"/accounts/#{params["account_id"]}/invites")
        |> render(:new, layout: {GitsWeb.Layouts, :account})
    end
  end
end
