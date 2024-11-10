defmodule GitsWeb.AuthPlug do
  use AshAuthentication.Plug, otp_app: :gits
  use GitsWeb, :verified_routes
  import Phoenix.Controller

  def handle_success(conn, activity, user, token) do
    activity |> IO.inspect()

    if is_api_request?(conn) do
      conn
      |> send_resp(
        200,
        Jason.encode!(%{
          authentication: %{
            success: true,
            token: token
          }
        })
      )
    else
      return_to = conn |> get_session(:return_to) || ~p"/"

      conn
      |> store_in_session(user)
      |> redirect(to: return_to)
    end
  end

  def handle_failure(conn, _activity, _reason) do
    if is_api_request?(conn) do
      conn
      |> send_resp(
        401,
        Jason.encode!(%{
          authentication: %{
            success: false
          }
        })
      )
    else
      conn
      |> send_resp(401, "<h2>Incorrect email or password</h2>")
    end
  end

  defp is_api_request?(conn), do: "application/json" in get_req_header(conn, "accept")
end
