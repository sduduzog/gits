defmodule GitsWeb.HostLive.Events.Show.Settings do
  require Ash.Query
  alias Gits.Accounts.Webhook
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  def update(assigns, socket) do
    Ash.Query.for_read(Webhook, :read)
    |> Ash.read(actor: assigns.current_user)
    |> case do
      {:ok, webhooks} ->
        socket
        |> assign(:webhooks, webhooks)
        |> assign(:current_user, assigns.current_user)
        |> assign(:handle, assigns.handle)
        |> assign(:event, assigns.event)
        |> assign(
          :form,
          Form.for_create(Webhook, :create, actor: assigns.current_user, forms: [auto?: true])
          |> Form.add_form(:event, type: :read, validate?: false)
        )
        |> ok()
    end
  end

  def handle_event("delete_webhook", %{"id" => id}, socket) do
    webhook =
      socket.assigns.webhooks
      |> Enum.find(&(&1.id == id))

    Ash.Changeset.for_destroy(webhook, :destroy)
    |> Ash.destroy(actor: socket.assigns.current_user)
    |> case do
      :ok ->
        socket
        |> assign(:webhooks, Enum.filter(socket.assigns.webhooks, &(&1.id != webhook.id)))
        |> noreply()
    end
  end

  def handle_event("manage_webhook", %{"id" => id}, socket) do
    webhook =
      socket.assigns.webhooks
      |> Enum.find(&(&1.id == id))

    socket
    |> assign(
      :form,
      Form.for_update(webhook, :update, actor: socket.assigns.current_user)
    )
    |> noreply()
  end

  def handle_event("manage_webhook", _, socket) do
    socket
    |> assign(
      :form,
      Form.for_create(Webhook, :create, actor: socket.assigns.current_user, forms: [auto?: true])
      |> Form.add_form(:event, type: :read, validate?: false)
    )
    |> noreply()
  end

  def handle_event("validate_webhook", unsigned_params, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("submit_webhook", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, webhook} ->
        socket
        |> assign(:webhooks, [webhook] ++ socket.assigns.webhooks)
        |> assign(:form, Form.for_update(webhook, :update, actor: socket.assigns.current_user))
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  def handle_event("archive", _, socket) do
    Ash.Changeset.for_destroy(socket.assigns.event, :destroy)
    |> Ash.destroy(actor: socket.assigns.current_user)
    |> case do
      :ok -> socket |> redirect(to: ~p"/hosts/#{socket.assigns.handle}/events")
    end
    |> noreply()
  end
end
