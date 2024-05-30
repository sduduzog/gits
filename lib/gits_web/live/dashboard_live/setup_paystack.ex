defmodule GitsWeb.DashboardLive.SetupPaystack do
  use GitsWeb, :live_view

  alias AshPhoenix.Form
  alias Gits.Dashboard.Account
  alias Gits.PaystackApi

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Setup Paystack")

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard_next_detail}}
  end

  def handle_params(unsigned_params, _uri, socket) do
    account =
      get_account(unsigned_params["slug"])

    banks =
      PaystackApi.list_banks()
      |> case do
        {:ok, list} -> Enum.map(list, fn bank -> {bank.name, bank.code} end)
      end

    user = socket.assigns.current_user

    form =
      account
      |> AshPhoenix.Form.for_update(:create_paystack_subaccount, as: "paystack", actor: user)

    socket =
      socket
      |> assign(:banks, banks)
      |> assign(:form, form)

    {:noreply, socket}
  end

  defp get_account(slug) do
    Account |> Ash.get!(slug)
  end

  def handle_event("validate", %{"paystack" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params, errors: false)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"paystack" => params}, socket) do
    form =
      socket.assigns.form
      |> Form.validate(params)

    socket =
      socket
      |> assign(:form, form)

    socket =
      with true <- form.valid?, {:ok, _} <- Form.submit(form) do
        socket
      else
        {:error, errors} ->
          IO.inspect(errors)
          socket

        false ->
          socket
          |> assign(:errors, Form.errors(form))
      end

    {:noreply, socket}
  end
end
