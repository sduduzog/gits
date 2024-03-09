defmodule GitsWeb.TicketController do
  use GitsWeb, :controller

  plug :assign_params

  def assign_params(%{path_info: [_, account_id, _, event_id, _]} = conn, _) do
    conn
    |> assign(:account_id, account_id)
    |> assign(:event_id, event_id)
  end

  def assign_params(conn, _) do
    conn
  end

  def index(conn, _) do
    conn
    |> assign(:tickets, [])
    |> render(:index, layout: {GitsWeb.Layouts, :event})
  end
end
