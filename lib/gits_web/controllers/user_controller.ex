defmodule GitsWeb.UserController do
  use GitsWeb, :controller

  def events(conn, _) do
    conn
    |> render(:events)
  end

  def ticket(conn, _) do
    conn
    |> put_layout(false)
    |> render(:ticket)
  end

  def tickets(conn, _) do
    conn
    |> put_layout(false)
    |> render(:tickets)
  end

  def profile(conn, _) do
    conn
    |> render(:profile)
  end

  def settings(conn, _) do
    conn
    |> render(:settings)
  end
end
