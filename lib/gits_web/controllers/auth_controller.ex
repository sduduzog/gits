defmodule GitsWeb.AuthController do
  use GitsWeb, :controller

  alias AshPhoenix.Form
  alias Gits.Accounts.User

  def sign_in(conn, params) do
    with %User{} <- conn.assigns.current_user do
      redirect(conn, to: ~p"/")
    end

    conn =
      case params["return_to"] do
        nil -> conn
        return_to when not is_nil(return_to) -> put_session(conn, :return_to, return_to)
      end

    email = params["email"]

    conn
    |> assign(
      :form,
      Form.for_action(User, :request_magic_link, as: "user")
      |> case do
        form when not is_nil(email) ->
          Form.set_data(form, %{email: email})

        form ->
          form
      end
    )
    |> put_layout(false)
    |> render(:sign_in)
  end

  def success(conn, {:password, :reset_request}, _user, _token) do
    conn
    |> put_flash(:info, "An email with instructions to reset your password has been sent.")
    |> redirect(to: "/sign-in")
  end

  def success(conn, _activity, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> delete_session(:return_to)
    |> assign(:current_user, user)
    |> redirect(to: return_to)
  end

  def failure(conn, {:password, :sign_in}, _reason) do
    conn
    |> put_flash(:warn, "The email or password you provided is incorrect. Please try again")
    |> redirect(to: "/sign-in")
  end

  def failure(conn, _activity, _reason) do
    conn |> put_status(401) |> render("failure.html")
  end

  def sign_out(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/")
  end

  def email_not_verified(conn, _params) do
    # conn |> render(:email_not_verified)
    conn |> render(:email_sent)
  end
end
