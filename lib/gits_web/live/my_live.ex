defmodule GitsWeb.MyLive do
  use GitsWeb, :live_view

  def render(%{live_action: :tickets} = assigns) do
    ~H"""
    <.header signed_in={not is_nil(@current_user)} current="Tickets" />
    <div>Tickets</div>
    """
  end

  def render(%{live_action: :orders} = assigns) do
    ~H"""
    <.header signed_in={not is_nil(@current_user)} current="Orders" />
    <div>orders</div>
    """
  end

  def render(%{live_action: :profile} = assigns) do
    ~H"""
    <.header signed_in={not is_nil(@current_user)} current="Profile" />
    <div>profile</div>
    """
  end

  def mount(_params, _session, socket) do
    IO.puts("shouldn't have mounted")
    socket |> ok()
  end
end
