defmodule GitsWeb.AdminLive.Index do
  alias Gits.Support.Job
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    socket |> ok(false)
  end

  def handle_params(_, _, socket) do
    user = socket.assigns.current_user

    case socket.assigns.live_action do
      :jobs ->
        Ash.Query.for_read(Job, :read)
        |> Ash.Query.sort(id: :desc)
        |> Ash.read(actor: user)
        |> case do
          {:ok, jobs} ->
            socket
            |> assign(:jobs, jobs)
            |> noreply()
        end

      _ ->
        socket |> noreply()
    end
  end
end
