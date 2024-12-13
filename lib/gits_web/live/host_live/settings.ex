defmodule GitsWeb.HostLive.Settings do
  alias AshPhoenix.Form
  alias Gits.PaystackApi
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Settings")
    |> assign(:section, nil)
    |> ok()
  end

  def handle_params(_, _, socket) do
    %{host: host, current_user: user} = socket.assigns

    case socket.assigns.live_action do
      :general ->
        assign(socket, :section, "General")
        |> assign(:form, Form.for_update(host, :update, actor: user))

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

        assign(socket, :section, "Billing & Payouts")
        |> assign(
          :banks,
          PaystackApi.list_banks!(:cache)
          |> Enum.map(&{&1.name, &1.code})
        )
        |> assign(:form, Form.for_update(host, :paystack_subaccount, actor: user))

      :index ->
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

        bank_name =
          PaystackApi.list_banks!(:cache)
          |> Enum.find(&(&1.code == host.paystack_settlement_bank))
          |> case do
            %{name: name} -> name
            _ -> nil
          end

        assign(socket, :page_title, "Settings")
        |> assign(:host, host)
        |> assign(:bank_name, bank_name)
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

    case socket.assigns.live_action do
      :general ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, host} ->
            assign(socket, :form, Form.for_update(host, :update, actor: user))

          {:error, form} ->
            assign(socket, :form, form)
        end

      :billing ->
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
        end
    end
    |> noreply()
  end
end
