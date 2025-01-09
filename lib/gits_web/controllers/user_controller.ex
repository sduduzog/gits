defmodule GitsWeb.UserController do
  use GitsWeb, :controller
  require Ash.Query

  def events(conn, _) do
    conn
    |> render(:events)
  end

  def tickets(conn, _) do
    conn |> render(:tickets)
  end

  def profile(conn, _) do
    %{current_user: user} = conn.assigns

    case user do
      false ->
        conn
        |> redirect(to: ~p"/sign-in?return_to=/my/profile")

      _ ->
        conn
        |> assign(:current_tab, :profile)
        |> assign(:page_title, "Profile")
        |> render(:profile)
    end
  end

  def edit_profile(conn, _) do
    conn |> render(:edit_profile)
  end

  def login_and_security(conn, _) do
    conn |> render(:login_and_security)
  end

  def settings(conn, _) do
    conn
    |> render(:settings)
  end
end
