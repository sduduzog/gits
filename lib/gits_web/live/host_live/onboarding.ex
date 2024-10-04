defmodule GitsWeb.HostLive.Onboarding do
  use GitsWeb, :host_live_view
  import GitsWeb.HostLive.Components
  import GitsWeb.HostLive.OnboardingComponents

  defp wizard_steps(action) do
    [
      {"Become a host", action == :sign_up},
      {"Create an event", action == :create_event},
      {"Time & place", action == :time_and_place},
      {"Add tickets", action == :add_tickets},
      {"Payout information", action == :payout_information},
      {"Summary", action == :summary}
    ]
  end

  defp current_title(action) do
    %{sign_up: "Become a host", create_event: "Create an event"} |> Map.get(action)
  end

  defp current_subtitle(action) do
    %{
      sign_up: "Create your host account to begin",
      create_event: "Start crafting your event experience",
      payout_information: "Provide your banking information for seamless payouts."
    }
    |> Map.get(action)
  end

  def render(assigns) do
    ~H"""
    <.wizard_wrapper title={current_title(@live_action)} subtitle={current_subtitle(@live_action)}>
      <:steps>
        <.wizard_step
          :for={{label, current} <- wizard_steps(@live_action)}
          label={label}
          current={current}
        />
      </:steps>
      <.onboarding_step_form current={@live_action}>
        <button
          :if={@live_action != :sign_up}
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
    |> push_navigate(to: ~p"/hosts/test/onboarding/event_id/add-tickets")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :add_tickets}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/onboarding/event_id/payout-information")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :payout_information}} = socket) do
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
