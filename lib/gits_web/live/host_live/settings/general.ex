defmodule GitsWeb.HostLive.Settings.General do
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  def update(assigns, socket) do
    socket
    |> assign(:inner_block, assigns.inner_block)
    |> assign(:current_user, assigns.current_user)
    |> assign(
      :form,
      Form.for_update(assigns.host, :details, actor: assigns.current_user)
    )
    |> ok()
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
        socket
        |> assign(
          :form,
          Form.for_update(host, :details, actor: socket.assigns.current_user)
        )
        |> noreply()
    end
  end
end
