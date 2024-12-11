defmodule GitsWeb.HostLive.Settings do
  alias AshPhoenix.Form
  alias Gits.PaystackApi
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Settings")
    |> ok()
  end

  def handle_params(_, _, socket) do
    %{host: host, current_user: user} = socket.assigns

    case socket.assigns.live_action do
      :billing ->
        host =
          Ash.load!(
            host,
            [
              :paystack_subaccount,
              :paystack_business_name,
              :paystack_account_number,
              :paystack_settlement_bank
            ],
            actor: user
          )

        assign(socket, :page_title, "Settings / Billing & Payouts")
        |> assign(
          :banks,
          PaystackApi.list_banks!(:cache)
          |> Enum.map(&{&1.name, &1.code})
        )
        |> assign(:form, Form.for_update(host, :paystack_subaccount, actor: user))

      :index ->
        assign(socket, :page_title, "Settings")
    end
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    form =
      socket.assigns.form
      |> Form.validate(unsigned_params["form"])

    socket
    |> assign(:form, form)
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    %{form: form, current_user: user} = socket.assigns

    Form.submit(form, params: unsigned_params["form"])
    |> case do
      {:ok, host} ->
        host =
          Ash.load!(
            host,
            [
              :paystack_subaccount,
              :paystack_business_name,
              :paystack_account_number,
              :paystack_settlement_bank
            ],
            actor: user
          )

        assign(socket, :host, host)
        |> assign(:form, Form.for_update(host, :paystack_subaccount, actor: user))
        |> noreply()
    end
  end
end
