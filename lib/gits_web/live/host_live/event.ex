defmodule GitsWeb.HostLive.Event do
  use GitsWeb, :host_live_view

  import GitsWeb.HostLive.EventComponents

  embed_templates "event_templates/*"

  def mount(_params, _session, socket) do
    socket |> assign(:page_title, "The Ultimate Cheese Festival") |> ok()
  end

  defp event_body(%{tab: :overview} = assigns) do
    ~H"""
    <.overview />
    """
  end

  defp event_body(%{tab: :attendees} = assigns) do
    ~H"""
    <.attendees />
    """
  end

  defp event_body(%{tab: :guests} = assigns) do
    ~H"""
    <.guests />
    """
  end

  defp event_body(assigns) do
    ~H"""
    <.settings_wizard_wrapper tab={@tab} />
    """
  end

  defp mapped_wizard_steps() do
    [
      {"Event details", "Enter the necessary details for your event listing.",
       :settings_event_details},
      {"Time & place", "Specify when and where your event will be taking place.",
       :settings_time_and_place},
      {"Feature graphic", "Upload an image to feature on your event page.",
       :settings_feature_graphic},
      {"Tickets", "Setup ticket types and pricing for your event.", :settings_tickets},
      {"Payout preferences", "Provide your banking information for seamless payouts.",
       :settings_payout_preferences},
      {"Summary", "Verify your event details and make any final changes.", :settings_summary}
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

  def handle_params(unsigned_params, uri, socket) do
    socket |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :settings_event_details}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/events/event_id/settings/time-and-place")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :settings_time_and_place}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/events/event_id/settings/feature-graphic")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :settings_feature_graphic}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/events/event_id/settings/tickets")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :settings_tickets}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/events/event_id/settings/payout-preferences")
    |> noreply()
  end

  def handle_event(
        "continue",
        _,
        %{assigns: %{live_action: :settings_payout_preferences}} = socket
      ) do
    socket
    |> push_navigate(to: ~p"/hosts/test/events/event_id/settings")
    |> noreply()
  end

  def handle_event("continue", _, %{assigns: %{live_action: :settings_summary}} = socket) do
    socket
    |> push_navigate(to: ~p"/hosts/test/dashboard")
    |> noreply()
  end
end
