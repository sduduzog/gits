defmodule GitsWeb.UploadListingLive do
  use GitsWeb, :live_view
  import GitsWeb.DashboardComponents

  def mount(_, session, socket) do
    params = session["params"]

    socket =
      assign(socket, :account_id, params["account_id"])
      |> assign(:event_id, params["event_id"])
      |> assign(:uploaded_files, [])
      |> allow_upload(:listing, accept: ~w(.jpg .jpeg .png), max_entries: 1)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    case uploaded_entries(socket, :listing) do
      {[entry], []} ->
        consume_uploaded_entry(socket, entry, fn %{path: _} ->
          {:ok, nil}
        end)
        |> IO.inspect()

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
