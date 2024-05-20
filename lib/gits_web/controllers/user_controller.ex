defmodule GitsWeb.UserController do
  use GitsWeb, :controller

  def events(conn, _) do
    conn
    |> put_layout({GitsWeb.Layouts, :next})
    |> render(:events)
  end
end
