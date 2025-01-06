defmodule GitsWeb.MyLive.Settings do
  require Ash.Query
  alias AshPhoenix.Form
  alias Gits.Accounts.Host
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    user = socket.assigns.current_user

    Host
    |> Ash.Query.filter(owner.id == ^user.id)
    |> Ash.read()
    |> case do
      {:ok, hosts} -> socket |> assign(:hosts, hosts)
    end
    |> assign(:uploaded_files, [])
    |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
    |> ok()
  end

  def handle_params(_, _, socket) do
    user = socket.assigns.current_user

    case socket.assigns.live_action do
      :profile ->
        socket
        |> assign(:form, Form.for_update(user, :update, actor: user))
        |> noreply()

      :partner ->
        socket |> noreply()
    end
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, user} ->
        socket
        |> assign(:current_user, user)
        |> assign(:form, Form.for_update(user, :update, actor: user))
        |> noreply()
    end
  end
end
