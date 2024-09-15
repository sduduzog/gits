defmodule GitsWeb.LiveUserAuth do
  import Phoenix.Component
  use GitsWeb, :verified_routes

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
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

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
