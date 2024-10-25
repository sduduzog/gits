defmodule GitsWeb.HostLive.EditEvent do
  alias Gits.Hosts.Event
  alias AshPhoenix.Form
  require Ash.Query
  use GitsWeb, :host_live_view

  embed_templates "manage_event/*"

  attr :title, :string, default: ""
  attr :href, :string, default: nil
  attr :complete, :boolean, default: false
  attr :current, :boolean, default: false
  attr :valid, :boolean, default: false
  attr :icon, :string, default: "hero-check"

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

  def render(assigns) do
    ~H"""
    <%= if assigns[:event] do %>
      <div class="flex items-center gap-2 p-2">
        <button onclick="history.back()" class="flex h-9 items-center gap-2 rounded-lg px-2">
          <.icon name="hero-chevron-left" class="size-5" />
          <span class="hidden text-sm font-medium lg:inline">Back</span>
        </button>

        <div class="flex gap-2 grow items-center border-l truncate pl-4 text-sm font-medium">
          <span class="text-zinc-500">Events</span>
          <.icon name="hero-slash-micro" class="text-zinc-500 shrink-0" />
          <span class="text-zinc-500 truncate"><%= @event.details.name %></span>
          <.icon name="hero-slash-micro" class="shrink-0" />
          <span class="">Edit event</span>
        </div>

        <button class="flex size-9 lg:w-auto items-center gap-2 justify-center shrink-0 rounded-lg lg:px-4">
          <.icon name="hero-megaphone" class="size-5" />
          <span class="text-sm hidden lg:inline">Help</span>
        </button>
      </div>
    <% else %>
      <div class="flex items-center gap-2 p-2">
        <.link
          replace={true}
          navigate={~p"/hosts/#{@host_handle}/events"}
          class="flex items-center gap-2 rounded-lg h-9 px-2"
        >
          <.icon name="hero-chevron-left" class="size-5" />
          <span class="text-sm font-medium lg:inline hidden">Back</span>
        </.link>

        <div class="flex gap-2 grow items-center border-l truncate pl-4 text-sm font-medium">
          <span class="text-zinc-500">Events</span>
          <.icon name="hero-slash-micro" class="shrink-0" />
          <span class="">Create event</span>
        </div>

        <button class="flex size-9 lg:w-auto items-center gap-2 justify-center shrink-0 rounded-lg lg:px-4">
          <.icon name="hero-megaphone" class="size-5" />
          <span class="text-sm hidden lg:inline">Help</span>
        </button>
      </div>
    <% end %>

    <div class="grow flex lg:pt-4 lg:flex-row flex-col">
      <div class="w-full lg:max-w-64 p-2 flex lg:flex-col gap-4 lg:gap-6">
        <%= if assigns[:event] do %>
          <.wizard_step
            current={@live_action == :details}
            href={Routes.host_edit_event_path(@socket, :details, @host_handle, @event.public_id)}
            complete={true}
            valid={true}
            title="Event details"
          />
          <.wizard_step
            current={@live_action == :time_and_place}
            href={
              Routes.host_edit_event_path(@socket, :time_and_place, @host_handle, @event.public_id)
            }
            title="Time & place"
          />
          <.wizard_step
            :if={false}
            current={@live_action == :feature_graphic}
            title="Feature graphic"
            href={~p"/hosts/#{@host_handle}/events/#{@event.public_id}"}
          />
          <.wizard_step :if={false} current={@live_action == :tickets} title="Tickets" />
          <.wizard_step
            :if={false}
            current={@live_action == :payout_preferences}
            title="Payout preferences"
          />
        <% else %>
          <.wizard_step current={@live_action == :details} title="Event details" />
          <.wizard_step current={@live_action == :time_and_place} title="Time & place" />
          <.wizard_step current={@live_action == :feature_graphic} title="Feature graphic" />
          <.wizard_step current={@live_action == :tickets} title="Tickets" />
          <.wizard_step current={@live_action == :payout_preferences} title="Payout preferences" />
        <% end %>
      </div>

      <div class="lg:mt-0 mt-4">
        <.event_details :if={@live_action == :details} form={@form} event_id={@event_id} />
        <.time_and_place :if={@live_action == :time_and_place} form={@form} />
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> ok()
  end

  def handle_params(%{"event_id" => event_id}, _uri, socket) do
    Event
    |> Ash.Query.filter(public_id == ^event_id)
    |> Ash.Query.load([:details, :ready_to_publish])
    |> Ash.read_one()
    |> case do
      {:ok, event} ->
        socket
        |> assign(:event, event)
        |> assign(:form, current_form(socket.assigns.live_action, event))
        |> assign(:event_id, event_id)
    end
    |> noreply()
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket
    |> assign(:form, current_form(socket.assigns.live_action))
    |> assign(:event_id, nil)
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

  defp current_form(:details) do
    Event
    |> Form.for_create(:create, forms: [auto?: true])
    |> Form.add_form([:details])
  end

  defp current_form(:details, event) do
    event
    |> Form.for_update(:details, forms: [auto?: true])
  end

  defp current_form(:time_and_place, event) do
    event
    |> Form.for_update(:details, forms: [auto?: true])
  end

  defp current_form(_, _) do
    nil
  end
end
