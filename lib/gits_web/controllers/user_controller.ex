defmodule GitsWeb.UserController do
  use GitsWeb, :controller

  def events(conn, _) do
    conn
    |> put_layout(html: {GitsWeb.Layouts, :next})
    |> render(:events)
  end

  def ticket(conn, _) do
    conn
    |> put_layout(html: {GitsWeb.Layouts, :next})
    |> render(:ticket)
  end

  def tickets(conn, _) do
    conn
    |> put_layout(html: {GitsWeb.Layouts, :next})
    |> render(:tickets)
  end

  def profile(conn, _) do
    conn
    |> put_layout(html: {GitsWeb.Layouts, :next})
    |> render(:profile)
  end

  def settings(conn, _) do
    conn
    |> put_layout(html: {GitsWeb.Layouts, :next})
    |> render(:settings)
  end
end
