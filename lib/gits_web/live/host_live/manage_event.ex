defmodule GitsWeb.HostLive.ManageEvent do
  alias Gits.Hosts.Event
  alias AshPhoenix.Form
  use GitsWeb, :host_live_view

  embed_templates "manage_event/*"

  defp wizard_steps(assigns) do
    ~H"""
    <div
      :for={
        {title, action} <- [
          {"Event details", :details},
          {"Time & place", :time_and_place},
          {"Feature Graphic", :foo},
          {"Tickets", :foo},
          {"Payout preferences", :foo},
          {"Publish", :foo}
        ]
      }
      class="flex items-center gap-2"
    >
      <%= if action == @current_action do %>
        <span class="inline-block h-1 w-6 lg:w-8 rounded-full bg-blue-500"></span>
        <span class="text-sm font-medium lg:inline"><%= title %></span>
      <% else %>
        <span class="inline-block h-1 lg:w-4 w-3 rounded-full bg-zinc-400 lg:ml-4"></span>
        <span class="hidden text-sm font-medium lg:inline"><%= title %></span>
      <% end %>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
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
        <span class="text-zinc-500 truncate">Events</span>
        <.icon name="hero-slash-micro" class="shrink-0" />
        <span class="truncate">Create an event</span>
      </div>

      <button class="flex size-9 lg:w-auto items-center gap-2 justify-center shrink-0 rounded-lg lg:px-4">
        <.icon name="hero-megaphone" class="size-5" />
        <span class="text-sm hidden lg:inline">Help</span>
      </button>
    </div>

    <h1 class="p-2 text-2xl font-semibold">Create an event</h1>

    <div class="grow flex lg:flex-row flex-col">
      <div class="w-full lg:max-w-64 p-2 flex lg:flex-col gap-4 lg:gap-6">
        <.wizard_steps current_action={@live_action} />
      </div>

      <div class="lg:mt-0 mt-4">
        <.event_details :if={@live_action == :details} form={@form} />
        <.time_and_place :if={@live_action == :time_and_place} form={@form} />
      </div>
    </div>

    <div class="px-2 py-4 pb-8 flex justify-end">
      <button
        class="h-9 flex px-4 bg-zinc-950 text-zinc-50 items-center rounded-lg"
        phx-click="continue"
      >
        <span class="font-semibold text-sm">Continue</span>
      </button>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:form, current_form(socket.assigns.live_action))
    |> ok()
  end

  def handle_params(unsigned_params, _uri, socket) do
    unsigned_params |> IO.inspect()
    socket |> noreply()
  end

  def handle_params(unsigned_params, _uri, socket) do
    unsigned_params |> IO.inspect()
    socket |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(:form, socket.assigns.form |> Form.validate(unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("continue", unsigned_params, socket) do
    socket
    |> handle_continue(socket.assigns.live_action, unsigned_params)
  end

  defp current_form(:create) do
    Event
    |> Form.for_create(:create, forms: [auto?: true])
    |> Form.add_form([:details])
  end

  defp current_form(:details) do
    Event
    |> Form.for_create(:create, forms: [auto?: true])
    |> Form.add_form([:details])
  end

  defp current_form(:time_and_place) do
    Event
    |> Form.for_create(:create, forms: [auto?: true])
    |> Form.add_form([:details])
  end

  defp handle_continue(socket, :create, params) do
    socket.assigns.form
    |> Form.validate(params["form"])
    |> Form.submit()
    |> case do
      {:ok, event} ->
        socket
        |> push_navigate(
          to: ~p"/hosts/#{socket.assigns.host_handle}/events/#{event.id}/manage/time-and-place"
        )

      {:error, form} ->
        socket |> assign(:form, form |> IO.inspect())
    end
    |> noreply()
  end
end
