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
end
