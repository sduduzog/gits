defmodule GitsWeb.AccountLive.SetupWizard do
  use GitsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>setup wizard <%= is_nil(@current_user) %></div>
    """
  end
end
