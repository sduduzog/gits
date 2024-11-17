defmodule GitsWeb.MyLive do
  use GitsWeb, :live_view

  def render(%{live_action: :tickets} = assigns) do
    ~H"""
    <div>Tickets</div>
    <.footer />
    """
  end

  def render(%{live_action: :orders} = assigns) do
    ~H"""
    <div>orders</div>
    <.footer />
    """
  end

  def render(%{live_action: :profile} = assigns) do
    ~H"""
    <div>profile</div>
    <.footer />
    """
  end

  def mount(_params, _session, socket) do
    IO.puts("shouldn't have mounted")
    socket |> ok()
  end
end
