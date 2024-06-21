defmodule GitsWeb.DashboardLive.Settings do
  use GitsWeb, :live_view

  require Ash.Query

  alias AshPhoenix.Form
  alias Gits.Dashboard.Account
  alias Gits.PaystackApi

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> Ash.Query.filter(members.user.id == ^user.id)
      |> Ash.read!()

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    banks =
      PaystackApi.list_banks!()
      |> Enum.map(fn bank -> {bank.name, bank.code} end)

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Settings")
      |> assign(:context_options, nil)
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:account_name, account.name)
      |> assign(:banks, banks)
      |> assign(:show_paystack_form, false)
      |> assign(:paystack_form, %{})
      |> assign(:show_paystack_editor, false)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket = socket |> assign(:form, %{})
    {:noreply, socket}
  end

  def handle_event("enable_billing", _unsigned_params, socket) do
    {:noreply,
     update(socket, :account, fn current_account, %{current_user: user} ->
       current_account
       |> Ash.Changeset.for_update(:enable_billing, %{billing_settings: %{}}, actor: user)
       |> Ash.update!()
       |> Ash.load!([:billing_enabled?, billing_settings: [:paystack_ready?]], actor: user)
     end)}
  end

  def handle_event("show_paystack_form", _unsigned_params, socket) do
    socket =
      socket
      |> update(:paystack_form, fn _current_form, %{account: account, current_user: user} ->
        account =
          account
          |> Ash.load!([:paystack_subaccount], actor: user)

        account
        |> Form.for_update(:update_paystack_account, as: "paystack", actor: user)
        |> Form.validate(account.paystack_subaccount)
      end)
      |> assign(:show_paystack_form, true)

    {:noreply, socket}
  end

  def handle_event("hide_paystack_form", _unsigned_params, socket) do
    socket = socket |> assign(:show_paystack_form, false)
    {:noreply, socket}
  end

  def handle_event("submit", %{"paystack" => params}, socket) do
    form =
      socket.assigns.paystack_form
      |> Form.validate(params)

    socket =
      with true <- form.valid?, {:ok, account} <- Form.submit(form) do
        socket
        |> update(:account, fn _current_account, _assigns -> account end)
        |> update(:show_paystack_form, &(!&1))
      else
        error ->
          IO.inspect(error)
          socket |> update(:show_paystack_form, &(!&1))
      end

    {:noreply, socket}
  end

  def handle_event(_, _unsigned_params, socket) do
    {:noreply, socket}
  end
end
