defmodule GitsWeb.AuthController do
  use GitsWeb, :controller

  alias Gits.Auth.Senders.SendEmailConfirmationLink
  alias AshAuthentication.AddOn.Confirmation
  alias Gits.Auth.Senders.UserConfirmation
  alias AshPhoenix.Form
  alias Gits.Auth.User

  def sign_in(conn, params) do
    with %Gits.Auth.User{} <- conn.assigns.current_user do
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
    |> put_layout(html: :auth)
    |> render(:sign_in)
  end

  def request_magic_link(conn, params) do
    user_params = params["user"]

    form =
      User
      |> Form.for_action(:request_magic_link, as: "user")
      |> Form.validate(user_params)

    email = user_params["email"]

    with true <- Regex.match?(~r/@/, email),
         {:ok, _} <- Turnstile.verify(params, conn.remote_ip),
         %Form{valid?: true} <- Form.validate(form, user_params),
         :ok <- create_user_via_email(email) do
      strategy =
        AshAuthentication.Info.strategy!(User, :magic_link)

      AshAuthentication.Strategy.action(strategy, :request, %{"email" => email})
      |> IO.inspect()

      conn |> redirect(to: ~p"/magic-link-sent?to=#{email}")
    else
      :created ->
        conn |> redirect(to: ~p"/magic-link-sent?to=#{email}")

      error ->
        IO.inspect(error)

        conn
        |> assign(
          :form,
          Form.for_action(User, :request_magic_link, as: "user")
        )
        |> put_flash(:error, "Invalid email")
        |> put_layout(html: :auth)
        |> render(:sign_in)
    end
  end

  defp create_user_via_email(email) do
    [username, _] =
      email
      |> String.split("@")

    User
    |> Ash.Changeset.for_create(
      :register_with_email,
      %{
        display_name: username,
        email: email
      },
      context: %{private: %{ash_authentication?: true}}
    )
    |> Ash.create()
    |> case do
      {:ok, _user} ->
        :ok

      {:error,
       %Ash.Error.Invalid{
         errors: [
           %Ash.Error.Changes.InvalidChanges{fields: [:email], message: "has already been taken"}
         ]
       }} ->
        :ok

      {:error, err} ->
        err |> IO.inspect()
        :error
    end
  end

  def magic_link_sent(conn, params) do
    conn
    |> assign(:email, params["to"])
    |> put_layout(html: :auth)
    |> render(:magic_link_sent)
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

  def sign_out(conn, _) do
    # return_to = get_session(conn, :return_to) || ~p"/"

    return_to = ~p"/"

    conn
    |> clear_session()
    |> redirect(to: return_to)
  end
end
