defmodule GitsWeb.HostLive.Events.Show.Dashboard do
  require Ash.Query
  alias Gits.Accounts.Webhook
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  def update(assigns, socket) do
    Ash.load(assigns.event, [], actor: assigns.current_user)
    |> case do
      {:ok, event} ->
        can_publish? =
          Ash.Changeset.for_update(event, :publish)
          |> Ash.can?(assigns.current_user)

        event_issues_pending? = not can_publish?

        socket
        |> assign(:can_publish?, can_publish?)
        |> assign(:event_issues_pending?, event_issues_pending?)
        |> assign(:state, event.state)
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
end
