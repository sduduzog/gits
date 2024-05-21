defmodule GitsWeb.UserController do
  use GitsWeb, :controller

  def events(conn, _) do
    conn
    |> put_layout(html: {GitsWeb.Layouts, :next})
    |> render(:events)
  end

  def tickets(conn, _) do
    conn
    |> put_layout(html: {GitsWeb.Layouts, :next})
    |> render(:events)
  end
end
