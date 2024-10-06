defmodule GitsWeb.HostLive.ManageEvent do
  use GitsWeb, :host_live_view
  import GitsWeb.HostLive.Components
  import GitsWeb.HostLive.ManageEventComponents

  defp mapped_wizard_steps() do
    [
      {"Create an event", "Start crafting your event experience.", :create_event},
      {"Time & place", "Specify when and where your event will be taking place.",
       :time_and_place},
      {"Upload feature graphic", "Upload an image to feature on your event page.",
       :upload_feature_graphic},
      {"Add tickets", "Setup ticket types and pricing for your event.", :add_tickets},
      {"Payout preferences", "Provide your banking information for seamless payouts.",
       :payout_preferences},
      {"Summary", "Verify your event details and make any final changes.", :summary}
    ]
  end

  defp wizard_steps(current_action) do
    mapped_wizard_steps()
    |> Enum.map(fn {_, _, action} = step -> {step, action == current_action} end)
  end

  defp get_current_step(current_action) do
    mapped_wizard_steps()
    |> Enum.find(fn {_, _, action} -> action == current_action end)
  end

  defp current_title(current_action) do
    get_current_step(current_action)
    |> (fn {title, _, _} -> title end).()
  end

  defp current_subtitle(current_action) do
    get_current_step(current_action)
    |> (fn {_, subtitle, _} -> subtitle end).()
  end

  def render(assigns) do
    ~H"""
    <.wizard_wrapper title={current_title(@live_action)} subtitle={current_subtitle(@live_action)}>
      <:steps>
        <.wizard_step
          :for={{{title, _, _}, current} <- wizard_steps(@live_action)}
          label={title}
          current={current}
        />
      </:steps>
      <.onboarding_step_form current={@live_action}>
        <button
          :if={@live_action != :sign_up and @live_action != :create_event}
          class="rounded-lg px-4 py-2 text-zinc-950 hover:bg-zinc-50"
          phx-click="skip"
        >
          <span class="text-sm font-medium">Skip</span>
        </button>

        <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
          <span class="text-sm font-medium">Continue</span>
        </button>
      </.onboarding_step_form>
    </.wizard_wrapper>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:title, "Quick setup")
    |> ok(:host_panel)
  end

  def handle_params(_unsigned_params, _uri, socket) do
    socket
    |> assign(:step, :event_details)
    |> noreply()
  end

  def handle_event("close", _, %{assigns: %{live_action: :create_event}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/dashboard", replace: true)
    |> noreply()
  end

  def handle_event("close", _, socket) do
    socket
    |> push_navigate(to: ~p"/host-with-us", replace: true)
    |> noreply()
  end

  def handle_event("skip", _unsigned_params, socket) do
    socket |> push_navigate(to: ~p"/hosts/test/dashboard", replace: true) |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :sign_up}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/onboarding/create-event")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :create_event}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/onboarding/event_id/time-and-place")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :time_and_place}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/onboarding/event_id/upload-feature-graphic")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :upload_feature_graphic}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/onboarding/event_id/add-tickets")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :add_tickets}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/onboarding/event_id/payout-preferences")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :payout_preferences}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/onboarding/event_id/summary")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :summary}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/dashboard")
    |> noreply()
  end
end
