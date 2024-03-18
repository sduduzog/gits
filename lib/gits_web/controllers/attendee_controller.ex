defmodule GitsWeb.AttendeeController do
  use GitsWeb, :controller

  plug :assign_params

  def assign_params(conn, _) do
    case conn.path_info do
      [_, account_id, _, event_id | _] ->
        conn
        |> assign(:account_id, account_id)
        |> assign(:event_id, event_id)

      [_, account_id, _] ->
        conn
        |> assign(:account_id, account_id)

      _ ->
        conn
    end
  end

  def index(conn, _) do
    render(conn, :index, layout: {GitsWeb.Layouts, :event})
  end

  def new(conn, params) do
    conn
    |> put_layout(false)
    |> Phoenix.LiveView.Controller.live_render(GitsWeb.NewAttendeeLive,
      session: params
    )
  end
end
