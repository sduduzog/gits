defmodule GitsWeb.HostLive.EditEvent do
  alias Gits.Hosts.TicketType
  alias Gits.Hosts.Event
  alias AshPhoenix.Form
  require Ash.Query
  use GitsWeb, :host_live_view

  embed_templates "edit_event_templates/*"

  attr :title, :string, default: ""
  attr :href, :string, default: nil
  attr :complete, :boolean, default: false
  attr :current, :boolean, default: false
  attr :valid, :boolean, default: false
  attr :icon, :string, default: "i-lucide-check"

  defp wizard_step(%{current: true} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <span class="inline-block h-1 w-6 lg:w-8 rounded-full bg-blue-500"></span>
      <span class="text-sm font-medium lg:inline"><%= @title %></span>
    </div>
    """
  end

  defp wizard_step(assigns) do
    ~H"""
    <.link patch={@href} replace={true} class="flex items-center gap-2">
      <%= if @valid do %>
        <.icon name={@icon} class="size-5 text-green-500 lg:ml-3" />
      <% else %>
        <span class="inline-block h-1 lg:w-4 w-3 rounded-full bg-zinc-400 lg:ml-4"></span>
      <% end %>
      <span class="hidden text-sm font-medium lg:inline"><%= @title %></span>
    </.link>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> ok()
  end

  def handle_params(%{"public_id" => public_id} = unsigned_params, _uri, socket) do
    unsigned_params |> IO.inspect()

    Event
    |> Ash.Query.filter(public_id == ^public_id)
    |> Ash.Query.load([:name, :ready_to_publish, :details, :ticket_types])
    |> Ash.read_one()
    |> case do
      {:ok, event} ->
        socket
        |> assign(:form, current_form(socket.assigns.live_action, event))
        |> assign(:event_name, event.name)
        |> assign(:ticket_types, event.ticket_types)
        |> assign(:event_public_id, public_id)
        |> show_create_ticket_modal(unsigned_params, event)
        |> show_edit_ticket_modal(unsigned_params, event)
    end
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket
    |> assign(:form, current_form(socket.assigns.live_action))
    |> assign(:event_public_id, nil)
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(
      :form,
      socket.assigns.form
      |> case do
        %{type: :update} = form ->
          form |> Form.validate(unsigned_params["form"])

        %{type: :create} = form ->
          form
          |> Form.validate(Map.put(unsigned_params["form"], :host_id, socket.assigns.host.id))
      end
    )
    |> noreply()
  end

  def handle_event("continue", unsigned_params, socket) do
    socket.assigns.form
    |> case do
      %{type: :update} = form ->
        form |> Form.validate(unsigned_params["form"])

      %{type: :create} = form ->
        form
        |> Form.validate(Map.put(unsigned_params["form"], :host_id, socket.assigns.host.id))
    end
    |> Form.submit()
    |> case do
      {:ok, event} ->
        socket
        |> push_navigate(
          to:
            Routes.host_edit_event_path(
              socket,
              :time_and_place,
              socket.assigns.host_handle,
              event.public_id
            )
        )

      {:error, form} ->
        socket |> assign(:form, form)
    end
    |> noreply()
  end

  def handle_event("tickets", unsigned_params, socket) do
    socket.assigns.form
    |> Form.validate(unsigned_params["form"])
    |> Form.submit()

    socket |> noreply()
  end

  defp current_form(:details) do
    Event
    |> Form.for_create(:create, forms: [auto?: true])
    |> Form.add_form([:details])
  end

  defp current_form(:details, event) do
    event
    |> Form.for_update(:details, forms: [auto?: true])
  end

  defp current_form(:tickets, event) do
    event
    |> Form.for_update(:update, forms: [auto?: true])
  end

  defp current_form(_, _) do
    nil
  end

  defp show_create_ticket_modal(socket, %{"new" => "ticket"}, event) do
    socket
    |> assign(
      :form,
      event
      |> Form.for_update(:add_ticket_type, forms: [auto?: true])
      |> Form.add_form([:type])
    )
    |> assign(:show_create_ticket_modal, true)
  end

  defp show_create_ticket_modal(socket, _, _) do
    socket
    |> assign(:show_create_ticket_modal, false)
  end

  defp show_edit_ticket_modal(socket, %{"edit" => "ticket", "id" => ticket_id}, event) do
    event
    |> Ash.load(ticket_types: [TicketType |> Ash.Query.filter(id == ^ticket_id)])
    |> case do
      {:ok, event} ->
        socket
        |> assign(
          :form,
          event
          |> Form.for_update(:edit_ticket_type, forms: [auto?: true])
        )
        |> assign(:show_edit_ticket_modal, true)
    end
  end

  defp show_edit_ticket_modal(socket, _, _) do
    socket
    |> assign(:show_edit_ticket_modal, false)
  end
end
