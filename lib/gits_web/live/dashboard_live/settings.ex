defmodule GitsWeb.DashboardLive.Settings do
  use GitsWeb, :dashboard_live_view

  alias AshPhoenix.Form
  alias Gits.PaystackApi

  def handle_params(unsigned_params, _uri, socket) do
    %{account: account} = socket.assigns

    banks =
      PaystackApi.list_banks!()
      |> Enum.map(fn bank -> {bank.name, bank.code} end)

    socket
    |> assign(:slug, unsigned_params["slug"])
    |> assign(:title, "Settings")
    |> assign(:account, account)
    |> assign(:account_name, account.name)
    |> assign(:banks, banks)
    |> assign(:show_paystack_form, false)
    |> assign(:paystack_form, %{})
    |> assign(:show_paystack_editor, false)
    |> assign(:form, %{})
    |> noreply()
  end

  def handle_event("enable_billing", _unsigned_params, socket) do
    update(socket, :account, fn current_account, %{current_user: user} ->
      current_account
      |> Ash.Changeset.for_update(:enable_billing, %{billing_settings: %{}}, actor: user)
      |> Ash.update!()
      |> Ash.load!([:billing_enabled?, billing_settings: [:paystack_ready?]], actor: user)
    end)
    |> noreply()
  end

  def handle_event("show_paystack_form", _unsigned_params, socket) do
    socket
    |> update(:paystack_form, fn _current_form, %{account: account, current_user: user} ->
      account =
        account
        |> Ash.load!([:paystack_subaccount], actor: user)

      account
      |> Form.for_update(:update_paystack_account, as: "paystack", actor: user)
      |> Form.validate(account.paystack_subaccount, errors: false)
    end)
    |> assign(:show_paystack_form, true)
    |> noreply()
  end

  def handle_event("hide_paystack_form", _unsigned_params, socket) do
    socket
    |> assign(:show_paystack_form, false)
    |> noreply()
  end

  def handle_event("submit", %{"paystack" => params}, socket) do
    form =
      socket.assigns.paystack_form
      |> Form.validate(params)

    with true <- form.valid?, {:ok, updated_account} <- Form.submit(form) do
      socket
      |> update(:account, fn _current_account, %{current_user: user} ->
        updated_account |> Ash.reload!(actor: user)
      end)
      |> update(:show_paystack_form, &(!&1))
    else
      _ ->
        socket |> update(:show_paystack_form, &(!&1))
    end
    |> noreply()
  end

  def handle_event(_, _unsigned_params, socket) do
    socket |> noreply()
  end
end
