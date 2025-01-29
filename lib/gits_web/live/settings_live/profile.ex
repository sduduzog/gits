defmodule GitsWeb.SettingsLive.Profile do
  alias AshPhoenix.Form
  use GitsWeb, :live_view

  embed_templates "components/*"

  def mount(_, _, socket) do
    socket
    |> assign(
      :form,
      Form.for_update(socket.assigns.current_user, :update, actor: socket.assigns.current_user)
    )
    |> assign(:uploaded_files, [])
    |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
    |> ok()
  end

  def handle_event("save-upload", _, socket) do
    filename =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        bucket_name = Application.get_env(:gits, :bucket_name)

        filename = Nanoid.generate(24) <> ".jpg"

        Image.open!(path)
        |> Image.thumbnail!("256x256", fit: :cover)
        |> Image.stream!(suffix: ".jpg", buffer_size: 5_242_880, quality: 100)
        |> ExAws.S3.upload(
          bucket_name,
          filename,
          content_type: "image/jpeg",
          cache_control: "public,max-age=3600"
        )
        |> ExAws.request()

        {:ok, filename}
      end)
      |> case do
        [filename] ->
          filename

        [] ->
          nil
      end

    Ash.Changeset.for_update(socket.assigns.current_user, :update, %{avatar: filename})
    |> Ash.update(actor: socket.assigns.current_user)
    |> case do
      {:ok, user} ->
        socket
        |> assign(:current_user, user)
        |> noreply()
    end
  end

  def handle_event("validate-upload", _, socket) do
    socket |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, user} ->
        socket
        |> assign(:current_user, user)
        |> assign(:form, Form.for_update(user, :update, actor: user))
        |> noreply()
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
