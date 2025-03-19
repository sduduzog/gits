defmodule GitsWeb.HostLive.Team do
  require Ash.Query
  alias Gits.Accounts.Invite
  alias AshPhoenix.Form
  alias Gits.Accounts.Host
  import GitsWeb.HostComponents
  use GitsWeb, :live_view

  on_mount {GitsWeb.LiveUserAuth, :live_user_required}

  def mount(params, _, socket) do
    user = socket.assigns.current_user

    Ash.Query.filter(Host, handle == ^params["handle"])
    |> Ash.read_one(actor: user)
    |> case do
      {:ok, %Host{} = host} ->
        socket
        |> GitsWeb.HostLive.assign_sidebar_items(__MODULE__, host)
        |> assign(:page_title, "Team")
        |> assign(:host, host)
        |> ok(:dashboard)

      _ ->
        socket |> ok(:not_found)
    end
  end

  def handle_params(_, _, socket) when socket.assigns.live_action == :members do
    Ash.load(socket.assigns.host, [roles: [:user_name, :user_email]],
      actor: socket.assigns.current_user
    )
    |> case do
      {:ok, host} ->
        socket
        |> assign(:roles, host.roles)
        |> assign(:send_invite_form, nil)
        |> noreply()
    end
  end

  def handle_params(_, _, socket) when socket.assigns.live_action == :invites do
    Ash.load(socket.assigns.host, [invites: :type_formatted], actor: socket.assigns.current_user)
    |> case do
      {:ok, host} ->
        socket
        |> assign(:invites, host.invites)
        |> assign(
          :send_invite_form,
          Form.for_update(host, :invite_member, actor: socket.assigns.current_user)
        )
        |> noreply()
    end
  end

  def handle_event("validate_send_invite", unsigned_params, socket) do
    socket
    |> assign(
      :send_invite_form,
      Form.validate(socket.assigns.send_invite_form, unsigned_params["form"])
    )
    |> noreply()
  end

  def handle_event("submit_send_invite", unsigned_params, socket) do
    Form.submit(socket.assigns.send_invite_form,
      params: unsigned_params["form"],
      action_opts: [load: [invites: :type_formatted]]
    )
    |> case do
      {:ok, host} ->
        socket
        |> assign(:invites, host.invites)
        |> assign(:send_invite_form, Form.for_update(socket.assigns.host, :invite_member))
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:send_invite_form, form)
        |> noreply()
    end
  end

  def handle_event("resend_invite", %{"id" => id}, socket) do
    Enum.find(socket.assigns.invites, &(&1.id == id))
    |> Invite.resend_email(actor: socket.assigns.current_user)

    socket |> noreply()
  end

  def handle_event("delete_invite", %{"id" => id}, socket) do
    Enum.find(socket.assigns.invites, &(&1.id == id))
    |> Ash.Changeset.for_destroy(:destroy)
    |> Ash.destroy(actor: socket.assigns.current_user)
    |> case do
      :ok ->
        socket
        |> assign(:invites, Enum.filter(socket.assigns.invites, &(&1.id != id)))
        |> noreply()

      _ ->
        socket |> noreply()
    end
  end
end
