defmodule GitsWeb.HostLive.Onboarding do
  require Ash.Query
  alias Gits.Hosting.Host
  alias AshPhoenix.Form

  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns

    case user do
      nil ->
        socket
        |> push_navigate(
          to:
            Routes.auth_path(socket, :sign_in, %{
              return_to: Routes.host_onboarding_path(socket, socket.assigns.live_action)
            })
        )
        |> ok(:unauthorized)

      %{} ->
        socket
        |> assign(:page_title, "Create a host account")
        |> assign(:uploaded_files, [])
        |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
        |> ok(:host_panel)
    end
  end

  def handle_params(_unsigned_params, _uri, socket) do
    %{current_user: user} = socket.assigns

    Host
    |> Ash.Query.filter(owner.id == ^user.id)
    |> Ash.read()
    |> case do
      {:ok, [host]} ->
        socket
        |> push_navigate(to: ~p"/hosts/#{host.handle}/dashboard")
        |> noreply()

      {:ok, []} ->
        socket
        |> assign(
          :form,
          Host
          |> Form.for_create(:create, as: "host", actor: user)
        )
        |> noreply()
    end
  end

  def handle_event("close", _unsigned_params, socket) do
    socket |> push_navigate(to: ~p"/") |> noreply()
  end

  def handle_event("save", unsigned_params, socket) do
    %{form: form, current_user: user} = socket.assigns

    filename =
      consume_uploaded_entries(socket, :logo, fn %{path: path}, _entry ->
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

    form
    |> Form.submit(
      params: Map.merge(unsigned_params["host"], %{"logo" => filename, "owner" => user})
    )
    |> case do
      {:ok, host} ->
        socket |> push_navigate(to: ~p"/hosts/#{host.handle}/events/create-new")

      {:error, form} ->
        socket |> assign(:form, form)
    end
    |> noreply()
  end
end
