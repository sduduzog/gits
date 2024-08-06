defmodule GitsWeb.DashboardLive.TeamInviteNewMember do
  use GitsWeb, :dashboard_live_view

  alias AshPhoenix.Form
  alias Gits.Dashboard.Account
  alias Gits.Dashboard.Invite

  # def mount(params, _session, socket) do
  #   user = socket.assigns.current_user
  #
  #   accounts =
  #     Account
  #     |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
  #     |> Ash.read!()
  #     |> Enum.map(fn item -> %{id: item.id, name: item.name} end)
  #
  #   account = Enum.find(accounts, fn item -> item.id == params["slug"] end)
  #
  #
  #   socket =
  #     socket
  #     |> assign(:slug, params["slug"])
  #     |> assign(:title, "Team")
  #     |> assign(:context_options, nil)
  #     |> assign(:action, params["action"])
  #     |> assign(:accounts, accounts)
  #     |> assign(:account_id, account.id)
  #     |> assign(:account_name, account.name)
  #
  #   {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  # end

  def handle_params(_unsigned_params, _uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    form = Invite |> Form.for_create(:create, actor: user)

    socket
    |> assign(:form, form)
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    update(socket, :form, fn current_form, _assigns ->
      current_form
      |> Form.validate(
        Map.merge(unsigned_params["form"], %{account: %{id: socket.assigns.account.id}})
      )
    end)
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    form =
      socket.assigns.form
      |> Form.validate(
        Map.merge(unsigned_params["form"], %{account: %{id: socket.assigns.account.id}})
      )

    with true <- form.valid?, {:ok, _} <- Form.submit(form) do
      slug = socket.assigns.slug

      push_navigate(socket, to: ~p"/accounts/#{slug}/team")
      |> noreply()
    else
      _all ->
        socket |> noreply()
    end
  end

  def render(assigns) do
    ~H"""
    <h1 class="mx-auto max-w-screen-lg text-xl font-semibold"><%= @account.name %>'s team</h1>
    <h2 class="mx-auto max-w-screen-lg text-3xl">Invite a new member</h2>
    <.simple_form
      :let={f}
      for={@form}
      class="grid md:grid-cols-2 gap-8 mx-auto max-w-screen-lg items-start"
      phx-change="validate"
      phx-submit="submit"
      phx-trigger-action={false}
    >
      <.input type="email" field={f[:email]} placeholder="jane@doe.com" label="Email address" />
      <.input
        label="Role"
        type="select"
        field={f[:role]}
        options={[
          Admin: :admin,
          "Sales Manager": :sales_manager,
          "Attendee Support": :attendee_support
        ]}
      />

      <div class="col-span-full">
        <button class="min-w-20 rounded-lg bg-zinc-800 p-3 px-4 font-medium text-white">
          Invite
        </button>
      </div>
    </.simple_form>
    """
  end
end
