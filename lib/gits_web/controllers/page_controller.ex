defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def settings(conn, _params) do
    render(conn, :settings)
  end

  def tickets(conn, _params) do
    render(conn, :tickets)
  end

  def search(conn, _params) do
    render(conn, :search)
  end
end
