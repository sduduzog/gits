defmodule GitsWeb.HostLive.Events.Show.Details do
  require Ash.Query
  alias Gits.Storefront.Event
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  def update(assigns, socket) do
    case assigns.event do
      %Event{} = event ->
        socket
        |> assign(:current_user, assigns.current_user)
        |> assign(:host, assigns.host)
        |> assign(:event, event)
        |> assign(:submit_action, "update")
        |> assign(
          :form,
          Form.for_update(event, :details, actor: assigns.current_user)
        )
        |> ok()

      nil ->
        socket
        |> assign(:current_user, assigns.current_user)
        |> assign(:host, assigns.host)
        |> assign(:submit_action, "create")
        |> assign(
          :form,
          Form.for_create(Event, :create, forms: [auto?: true], actor: assigns.current_user)
          |> Form.add_form([:host], type: :read, validate?: false)
        )
        |> ok()
    end
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("update", unsigned_params, socket) do
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

  def handle_event("create", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        socket
        |> push_patch(
          to: ~p"/hosts/#{socket.assigns.host.handle}/events/#{event.public_id}/details",
          replace: true
        )
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end
end
