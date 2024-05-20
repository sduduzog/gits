defmodule GitsWeb.UserController do
  use GitsWeb, :controller

  def events(conn, _) do
    conn |> render(:events)
  end
end
