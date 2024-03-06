defmodule GitsWeb.AuthController do
  use GitsWeb, :controller
  use AshAuthentication.Phoenix.Controller

  def sign_in(conn, params) do
    with %Gits.Accounts.User{} <- conn.assigns.current_user do
      redirect(conn, to: ~p"/")
    end

    conn
    |> put_session(:return_to, params["return_to"])
    |> put_layout(false)
    |> Phoenix.LiveView.Controller.live_render(GitsWeb.AuthLive.Form,
      session: Map.merge(params, %{"action" => "sign_in"})
    )
  end

  def register(conn, params) do
    with %Gits.Accounts.User{} <- conn.assigns.current_user do
      redirect(conn, to: ~p"/")
    end

    conn
    |> put_session(:return_to, params["return_to"])
    |> put_layout(false)
    |> Phoenix.LiveView.Controller.live_render(GitsWeb.AuthLive.Form,
      session: Map.merge(params, %{"action" => "register"})
    )
  end

  def forgot_password(conn, _) do
    conn
    |> put_layout(false)
    |> Phoenix.LiveView.Controller.live_render(GitsWeb.AuthLive.ForgotPassword)
  end

  def success(conn, activity, user, _token) do
    IO.inspect(activity)
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> redirect(to: return_to)
  end

  def failure(conn, _activity, reason) do
    IO.inspect(reason)
    conn |> put_status(401) |> render("failure.html")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session()
    |> redirect(to: return_to)
  end
end
