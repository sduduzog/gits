defmodule GitsWeb.SettingsLive.Profile do
  alias Gits.Bucket.Image
  alias AshPhoenix.Form
  alias Gits.Accounts.User
  use GitsWeb, :live_view

  embed_templates "components/*"

  def mount(_, _, socket) do
    Ash.load(socket.assigns.current_user, [avatar: :url], actor: socket.assigns.current_user)
    |> case do
      {:ok, %User{} = user} ->
        socket
        |> assign(:avatar, user.avatar)
        |> assign(
          :form,
          Form.for_update(socket.assigns.current_user, :update,
            actor: socket.assigns.current_user
          )
        )
        |> assign(:uploaded_files, [])
        |> allow_upload(:avatar,
          accept: ~w(.jpg .jpeg .png .webp),
          max_entries: 1,
          max_file_size: 1_048_576 * 2,
          auto_upload: true,
          progress: &handle_upload_progress/3
        )
        |> ok()
    end
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
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

  defp handle_upload_progress(:avatar, entry, socket) do
    if entry.done? do
      [image] =
        consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
          Ash.Changeset.for_update(socket.assigns.current_user, :avatar, %{avatar: %{path: path}})
          |> Ash.update(actor: socket.assigns.current_user)
          |> case do
            {:ok, user} -> {:ok, user.avatar}
          end
        end)

      socket
      |> assign(:avatar, image)
      |> noreply()
    else
      socket |> noreply()
    end
  end
end
