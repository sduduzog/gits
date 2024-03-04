defmodule GitsWeb.AuthController do
  use GitsWeb, :controller
  use AshAuthentication.Phoenix.Controller
  use PhoenixHTMLHelpers
  alias AshPhoenix.Form

  def sign_in(conn, _params) do
    conn
    |> assign(
      :form,
      Form.for_create(Gits.Accounts.User, :register_with_password,
        api: Gits.Accounts,
        as: "user"
      )
    )
    |> render(:sign_in, layout: {GitsWeb.Layouts, "auth.html"})
  end

  def register(conn, _params) do
    render(conn, :register, layout: {GitsWeb.Layouts, "auth.html"})
  end

  def success(conn, _activity, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> redirect(to: return_to)
  end

  def failure(conn, _activity, _reason) do
    conn |> put_status(401) |> render("failure.html")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session()
    |> redirect(to: return_to)
  end
end
