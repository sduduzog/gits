defmodule GitsWeb.HostLive.Events.Show.Details do
  require Ash.Query
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  def update(assigns, socket) do
    socket
    |> assign(:current_user, assigns.current_user)
    |> assign(:host, assigns.host)
    |> assign(:event, assigns.event)
    |> assign(
      :form,
      Form.for_update(assigns.event, :details, actor: assigns.current_user)
    )
    |> ok()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:form, Form.for_update(event, :details, actor: socket.assigns.current_user))
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end
end
