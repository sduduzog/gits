defmodule GitsWeb.HostLive.Settings.Billing do
  alias AshPhoenix.Form
  alias Gits.PaystackApi
  import GitsWeb.HostComponents
  use GitsWeb, :live_component

  def update(assigns, socket) do
    Ash.load(
      assigns.host,
      [
        :paystack_subaccount,
        :paystack_business_name,
        :paystack_account_number,
        :paystack_settlement_bank
      ],
      actor: assigns.current_user
    )
    |> case do
      {:ok, host} ->
        socket
        |> assign(:current_user, assigns.current_user)
        |> assign(:host, assigns.host)
        |> assign(
          :banks,
          PaystackApi.list_banks!(:cache)
          |> Enum.map(&{&1.name, &1.code})
        )
        |> assign(
          :form,
          Form.for_update(host, :paystack_subaccount, actor: assigns.current_user)
        )
        |> ok()
    end
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
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
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
            actor: socket.assigns.current_user
          )

        assign(socket, :host, host)
        |> assign(
          :form,
          Form.for_update(host, :paystack_subaccount, actor: socket.assigns.current_user)
        )
    end
    |> noreply()
  end
end
