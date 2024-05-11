defmodule GitsWeb.TeamMemberController do
  use GitsWeb, :controller

  plug :set_layout

  defp set_layout(conn, _) do
    put_layout(conn, html: :dashboard)
  end

  def index(conn, _params) do
    assign(
      conn,
      :roles,
      []
    )
    |> assign(
      :invites,
      []
    )
    |> render(:index)
  end
end
