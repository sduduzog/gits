defmodule GitsWeb.PageController do
  use GitsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def settings(conn, _params) do
    with %Gits.Accounts.User{} <- conn.assigns.current_user do
      render(conn, :settings)
    end

    return_to = conn |> current_path()

    conn
    |> redirect(to: ~p"/sign-in?return_to=#{return_to}")
  end

  def tickets(conn, _params) do
    render(conn, :tickets)
  end

  def search(conn, _params) do
    render(conn, :search)
  end
end
