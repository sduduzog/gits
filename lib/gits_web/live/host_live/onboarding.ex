defmodule GitsWeb.HostLive.Onboarding do
  require Ash.Query
  alias Gits.Accounts.Host
  alias AshPhoenix.Form

  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns

    case user do
      nil ->
        socket
        |> push_navigate(
          to:
            Routes.auth_path(socket, :sign_in, %{
              return_to: Routes.host_onboarding_path(socket, socket.assigns.live_action)
            })
        )
        |> ok(:unauthorized)

      %{} ->
        socket
        |> assign(:page_title, "Create a host account")
        |> assign(:uploaded_files, [])
        |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
        |> ok(:wizard)
    end
  end

  def handle_params(_, _, socket) do
    %{current_user: user} = socket.assigns

    Host
    |> Ash.Query.filter(owner.id == ^user.id)
    |> Ash.read()
    |> case do
      {:ok, [host]} ->
        socket
        |> push_navigate(to: ~p"/hosts/#{host.handle}/dashboard")
        |> noreply()

      {:ok, []} ->
        assign(socket, :user, user)
        |> assign(
          :form,
          Host
          |> Form.for_create(:create,
            forms: [auto?: true],
            actor: user
          )
          |> Form.add_form([:owner], type: :read, validate?: false)
          |> Form.add_form([:role], validate?: false)
          |> Form.add_form([:role, :user], type: :read, validate?: false)
        )
        |> noreply()
    end
  end

  def handle_event("close", _unsigned_params, socket) do
    socket |> push_navigate(to: ~p"/") |> noreply()
  end

  def handle_event("save", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, host} ->
        socket |> push_navigate(to: ~p"/hosts/#{host.handle}/events/create")

      {:error, form} ->
        socket |> assign(:form, form)
    end
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    Form.validate(socket.assigns.form, unsigned_params["form"])

    socket |> noreply()
  end
end
