defmodule GitsWeb.HostLive.Settings do
  alias AshPhoenix.Form
  alias Gits.PaystackApi
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Settings")
    |> ok()
  end

  def handle_params(_, _, %{assigns: %{live_action: :payouts}} = socket) do
    user = socket.assigns.current_user

    host =
      Ash.load!(
        socket.assigns.host,
        [
          :paystack_subaccount,
          :paystack_business_name,
          :paystack_account_number,
          :paystack_settlement_bank
        ],
        actor: user
      )

    banks =
      PaystackApi.list_banks!(:cache)
      |> Enum.map(&{&1.name, &1.code})

    form =
      host
      |> Form.for_update(:paystack_subaccount, actor: user)

    socket
    |> assign(:banks, banks)
    |> assign(:form, form)
    |> assign(:host, host)
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket |> noreply()
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
