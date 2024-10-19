defmodule GitsWeb.LiveUserAuth do
  require Ash.Query
  alias Gits.Hosts.Host
  import Phoenix.Component
  use GitsWeb, :verified_routes

  defp otp_app_from_socket(socket) do
    socket.assigns[:otp_app] ||
      :otp_app
      |> socket.endpoint.config()
  end

  defp socket_with_current_subject(session, socket) do
    {current_subject_name, current_subject} =
      socket
      |> otp_app_from_socket()
      |> AshAuthentication.authenticated_resources()
      |> Stream.map(&{to_string(AshAuthentication.Info.authentication_subject_name!(&1)), &1})
      |> Enum.reduce(socket, fn {subject_name, resource}, _ ->
        current_subject_name = String.to_existing_atom("current_#{subject_name}")

        current_subject =
          if value = session[subject_name] do
            case AshAuthentication.subject_to_user(value, resource, tenant: nil, context: %{}) do
              {:ok, user} -> user
              _ -> nil
            end
          end

        {current_subject_name, current_subject}
      end)

    socket
    |> assign_new(current_subject_name, fn -> current_subject end)
  end

  defp socket_with_host(socket, params) do
    case params do
      %{"handle" => handle} ->
        {:ok, host} =
          Host
          |> Ash.Query.filter(handle == ^handle)
          |> Ash.read_one()

        socket
        |> assign_new(:host_handle, fn -> handle end)
        |> assign_new(:host, fn -> host end)

      _ ->
        socket
    end
  end

  def on_mount(:live_user_optional, _params, session, socket) do
    socket =
      socket_with_current_subject(session, socket)

    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, params, session, socket) do
    socket =
      socket_with_current_subject(session, socket)
      |> socket_with_host(params)

    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.attach_hook(:redirect_and_halt, :handle_params, fn _, url, socket ->
          return_to = URI.parse(url) |> Map.get(:path)
          {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in?return_to=#{return_to}")}
        end)

      {:cont, socket}
    end
  end

  def on_mount(:live_no_user, _params, session, socket) do
    socket = socket_with_current_subject(session, socket)

    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
