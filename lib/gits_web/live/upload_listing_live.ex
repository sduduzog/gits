defmodule GitsWeb.UploadListingLive do
  use GitsWeb, :live_view
  import GitsWeb.DashboardComponents

  def mount(_, session, socket) do
    ExAws.Config.new(:s3) |> IO.inspect()
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
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          Image.open!(path)
          |> Image.thumbnail!("480x600", fit: :cover)
          |> Image.stream!(suffix: ".jpg", buffer_size: 5_242_880, quality: 100)
          |> Gits.Bucket.upload_listing_image(socket.assigns.account_id, socket.assigns.event_id)

          {:ok, nil}
        end)

        {:noreply,
         redirect(socket,
           to:
             ~p"/accounts/#{socket.assigns.account_id}/events/#{socket.assigns.event_id}/settings"
         )}

      _ ->
        {:noreply, socket}
    end
  end
end
