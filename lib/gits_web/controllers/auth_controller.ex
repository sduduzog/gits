defmodule GitsWeb.AuthController do
  use GitsWeb, :controller
  use AshAuthentication.Phoenix.Controller

  alias AshAuthentication.AddOn.Confirmation
  alias Gits.Auth.Senders.UserConfirmation

  def sign_in(conn, params) do
    with %Gits.Auth.User{} <- conn.assigns.current_user do
      redirect(conn, to: ~p"/")
    end

    conn =
      case params["return_to"] do
        return_to when not is_nil(return_to) -> put_session(conn, :return_to, return_to)
        _ -> conn
      end

    conn
    |> put_layout(false)
    |> Phoenix.LiveView.Controller.live_render(GitsWeb.AuthLive.Form,
      session: Map.merge(params, %{"action" => "sign_in"})
    )
  end

  def register(conn, params) do
    with %Gits.Auth.User{} <- conn.assigns.current_user do
      redirect(conn, to: ~p"/")
    end

    conn =
      case params["return_to"] do
        return_to when not is_nil(return_to) -> put_session(conn, :return_to, return_to)
        _ -> conn
      end

    conn
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

  def success(conn, {:password, :reset_request}, _user, _token) do
    conn
    |> put_flash(:info, "An email with instructions to reset your password has been sent.")
    |> redirect(to: "/sign-in")
  end

  def success(conn, _activity, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
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
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session()
    |> redirect(to: return_to)
  end

  def email_not_verified(conn, _params) do
    # conn |> render(:email_not_verified)
    conn |> render(:email_sent)
  end

  def resend_verification_email(conn, params) do
    case Turnstile.verify(params, conn.remote_ip) do
      {:ok, _} ->
        if conn.assigns.current_user && conn.assigns.current_user.confirmed_at == nil do
          changeset =
            Ash.Changeset.for_update(conn.assigns.current_user, :send_confirmation_email)

          strategy =
            AshAuthentication.Info.strategy!(conn.assigns.current_user, :confirm)

          {:ok, token} =
            Confirmation.confirmation_token(
              strategy,
              changeset,
              changeset.data
            )

          UserConfirmation.send(changeset.data, token, [])
        end

        conn |> render(:email_sent)

      {:error, _} ->
        conn
        |> put_flash(:error, "Please try submitting again")
        |> redirect(to: ~p"/email-not-verified")
    end
  end
end
